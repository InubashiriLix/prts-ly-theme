#!/usr/bin/env python3
"""Integration tests for embedded modules and deployment path generation."""
from pathlib import Path
import json
import shutil
import shlex
import subprocess
import tempfile
import unittest

from build import ANIMATION, ROOT, bundle, stage


class BuildTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="prts-test-")
        self.root = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def lua(self, source):
        return subprocess.run(["luajit", "-e", source], capture_output=True, text=True)

    def fixture(self, source):
        root = self.root / "modules"
        root.mkdir()
        (root / "modules.txt").write_text("item\n")
        (root / "item.lua").write_text(source)
        return root

    def test_cache_and_unknown_module(self):
        root = self.fixture("return {}")
        (root / "anime.lua").write_text('''
assert(require("item") == require("item"))
local ok, err = pcall(require, "unknown")
assert(not ok and string.find(err, "unknown embedded module"))
''')
        result = self.lua(bundle(root))
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_cycle(self):
        root = self.fixture('return require("item")')
        (root / "anime.lua").write_text('require("item")')
        result = self.lua(bundle(root))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("circular module item", result.stderr)

    def test_missing_dependency(self):
        root = self.fixture('return require("missing")')
        (root / "anime.lua").write_text('require("item")')
        with self.assertRaisesRegex(ValueError, "unlisted module missing"):
            bundle(root)
        (root / "item.lua").unlink()
        with self.assertRaisesRegex(ValueError, "Missing module"):
            bundle(root)

    def test_stage_paths_and_preview(self):
        output = self.root / 'path with "quotes" & spaces'
        stage(output, output, preview=True)
        code = f'dofile({json.dumps(str(output / "config.lua"))}); '
        code += 'assert(ly.start_cmd == nil and ly.save_file_dir == nil); '
        code += 'assert(ly.service_name == "prts-preview-no-auth"); '
        code += 'assert(ly.lua_animation_file == ' + json.dumps(str(output / "animation/anime.lua")) + ')'
        result = self.lua(code)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("/etc/ly/", (output / "config.lua").read_text().split("-- Generated deployment paths.")[1])

    def test_reduced_motion_and_no_entrance(self):
        root = self.root / "animation"
        shutil.copytree(ANIMATION, root)
        for opts in ["entrance=false, reduced_motion=false", "entrance=true, reduced_motion=true"]:
            (root / "theme/options.lua").write_text("return {" + opts + "}")
            target = self.root / "bundle.lua"
            target.write_text(bundle(root))
            result = subprocess.run(["luajit", str(ROOT / "tools/test_animation.lua"), str(target)],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_timeline_options(self):
        timeline = json.dumps(str(ANIMATION / "core/timeline.lua"))
        result = self.lua(f'''
local clock = dofile({timeline})
local options = {{entrance=true, reduced_motion=true}}
local a, b = clock.sample(0, options), clock.sample(9000000, options)
assert(a.seconds == b.seconds and a.ready and not a.moving)
clock = dofile({timeline})
assert(clock.sample(0, {{entrance=false}}).ready)
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_installer_backup_and_paths(self):
        target = self.root / "installed config"
        target.mkdir()
        (target / "config.lua").write_text("-- existing configuration\n")
        (target / "keep.txt").write_text("preserve me")
        result = subprocess.run([str(ROOT / "tools/install.sh"), str(target)],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        backups = list(self.root.glob("installed config.backup-*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / "config.lua").read_text(), "-- existing configuration\n")
        self.assertEqual((target / "keep.txt").read_text(), "preserve me")
        result = self.lua(f'dofile({json.dumps(str(target / "config.lua"))}); '
                          f'assert(ly.start_cmd == {json.dumps(shlex.quote(str(target / "startup.sh")))}); '
                          f'assert(ly.save_file_dir == {json.dumps(str(target))})')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
