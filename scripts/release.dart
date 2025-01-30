// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';

void main(List<String> args) {
  checkForUnstagedChanges();

  ArgParser parser = ArgParser()
    ..addFlag(
      'type',
      abbr: 't',
      negatable: false,
    );

  ArgResults argResults = parser.parse(args);

  if (argResults.rest.isNotEmpty) {
    String releaseType = argResults.rest[0];

    String rootDir = Directory.current.path;
    File pubspecFile = File('$rootDir/pubspec.yaml');
    String pubspecContents = pubspecFile.readAsStringSync();

    RegExp appVersionPattern = RegExp(
      r'(version:\s)(\d+)\.(\d+)\.(\d+)',
    );

    RegExpMatch? appVersionMatch =
        appVersionPattern.firstMatch(pubspecContents);

    if (appVersionMatch == null) {
      print('❌ App version not found');
      exit(1);
    }

    String updatedPubspecContents = '';

    switch (releaseType) {
      case 'major':
        updatedPubspecContents = replaceContents(
          pubspecContents,
          appVersionPattern,
          2,
        );

        break;

      case 'minor':
        updatedPubspecContents = replaceContents(
          pubspecContents,
          appVersionPattern,
          3,
        );

        break;

      case 'patch':
        updatedPubspecContents = replaceContents(
          pubspecContents,
          appVersionPattern,
          4,
        );

        break;

      default:
        print('❌ Invalid release type');
        exit(1);
    }

    if (updatedPubspecContents.isNotEmpty) {
      pubspecFile.writeAsStringSync(updatedPubspecContents);
    }

    RegExpMatch? updatedVersionMatch =
        appVersionPattern.firstMatch(updatedPubspecContents);

    if (updatedVersionMatch == null) {
      print('❌ Failed after updating pubspec');
      exit(1);
    }

    // Update CHANGELOG.md
    updateChangelog(updatedVersionMatch);

    // Create and push a new Git tag
    createGitTag(updatedVersionMatch);

    exit(0);
  }

  print('❌ Missing release type');
  exit(1);
}

String replaceContents(String initialContents, RegExp pattern, int index) {
  return initialContents.replaceAllMapped(pattern, (match) {
    String finalContents = '${match.group(1)}';

    if (index == 2) {
      finalContents += '${incrementValue(match.group(2))}.0.0';
    } else if (index == 3) {
      finalContents += '${match.group(2)}.${incrementValue(match.group(3))}.0';
    } else if (index == 4) {
      finalContents +=
          '${match.group(2)}.${match.group(3)}.${incrementValue(match.group(4))}';
    }

    print('🎉 New $finalContents');
    return finalContents;
  });
}

int incrementValue(String? value) {
  return int.parse(value as String) + 1;
}

void updateChangelog(RegExpMatch versionMatch) {
  String version =
      '${versionMatch.group(2)}.${versionMatch.group(3)}.${versionMatch.group(4)}';
  File changelogFile = File('CHANGELOG.md');
  String changelogContents = changelogFile.readAsStringSync();

  // Get the previous Git tag
  ProcessResult previousTagResult =
      Process.runSync('git', ['describe', '--tags', '--abbrev=0']);

  String previousTag = '';
  if (previousTagResult.exitCode == 0) {
    previousTag = previousTagResult.stdout.toString().trim();
  } else {
    print(
        '⚠️ No previous Git tag found. Including all commits in the changelog.');
  }

  // Get the commits since the previous tag (or all commits if no previous tag exists)
  String gitLogRange = previousTag.isEmpty ? 'HEAD' : '$previousTag..HEAD';
  ProcessResult commitsResult = Process.runSync(
    'git',
    ['log', gitLogRange, '--pretty=format:%s'],
  );

  if (commitsResult.exitCode != 0) {
    print('❌ Failed to get commits: ${commitsResult.stderr}');
    exit(1);
  }

  String commits = commitsResult.stdout.toString().trim();

  String formattedCommits =
      commits.split('\n').map((commit) => '  - $commit').join('\n');

  String newChangelogEntry = '''
## $version

$formattedCommits
''';

  // Prepend the new entry to the existing changelog
  String updatedChangelogContents = newChangelogEntry + changelogContents;
  changelogFile.writeAsStringSync(updatedChangelogContents);

  ProcessResult addResult = Process.runSync('git', ['add', '.']);

  if (addResult.exitCode != 0) {
    print('❌ Failed to stage changes: ${addResult.stderr}');
    exit(1);
  }

  // Commit changes with a default message
  ProcessResult commitResult =
      Process.runSync('git', ['commit', '-m', 'Release v$version']);

  if (commitResult.exitCode != 0) {
    print('❌ Failed to commit changes: ${commitResult.stderr}');
    exit(1);
  }

  print('📝 Updated CHANGELOG.md with new release $version');
}

void createGitTag(RegExpMatch versionMatch) {
  String version =
      '${versionMatch.group(2)}.${versionMatch.group(3)}.${versionMatch.group(4)}';

  // Create a new Git tag
  ProcessResult createTagResult = Process.runSync(
      'git', ['tag', '-a', 'v$version', '-m', 'Release v$version']);

  if (createTagResult.exitCode != 0) {
    print('❌ Failed to create Git tag: ${createTagResult.stderr}');
    exit(1);
  }

  print('🏷  Created Git tag v$version');

  // Push the new tag to the remote repository
  ProcessResult pushTagResult =
      Process.runSync('git', ['push', 'origin', 'v$version']);

  if (pushTagResult.exitCode != 0) {
    print('❌ Failed to push Git tag: ${pushTagResult.stderr}');
    exit(1);
  }

  print('🚀 Pushed Git tag v$version to remote');
}

void checkForUnstagedChanges() {
  // Check for unstaged changes
  ProcessResult statusResult =
      Process.runSync('git', ['status', '--porcelain']);

  if (statusResult.exitCode != 0) {
    print('❌ Failed to check Git status: ${statusResult.stderr}');
    exit(1);
  }

  String statusOutput = statusResult.stdout.toString().trim();

  if (statusOutput.isNotEmpty) {
    print('⚠️  You have unstaged changes');

    // Ask the user if they want to commit the changes automatically
    stdout.write('Do you want to commit these changes automatically? (y/n): ');
    String? response = stdin.readLineSync()?.toLowerCase();

    if (response == 'y' || response == 'yes') {
      // Stage all changes
      ProcessResult addResult = Process.runSync('git', ['add', '.']);

      if (addResult.exitCode != 0) {
        print('❌ Failed to stage changes: ${addResult.stderr}');
        exit(1);
      }

      // Commit changes with a default message
      ProcessResult commitResult = Process.runSync(
          'git', ['commit', '-m', 'Auto-commit before release']);

      if (commitResult.exitCode != 0) {
        print('❌ Failed to commit changes: ${commitResult.stderr}');
        exit(1);
      }

      print('✅ Successfully committed unstaged changes.');
    } else {
      print(
          '❌ Release aborted. Please commit or stash your changes and try again.');
      exit(1);
    }
  }
}
