# 2 contribute

If you feel like contributing there are a couple of ways to do this

1. You can add new super high speed bash code, optimising existing, rewrite for 
    broader support of bash environments across OS's
1. You can add domains to either the hosts.list in the source folder.
1. You don't have to locate the right line/order to add you contribution, the 
    CI/CD will do the sorting.

# Workflow

The workflow is a bit clumsy, but the most reliable and simple.
    1. You add an issue with you question, feature request or ? 
    1. You open a MR (Merge Request) where you'll add your contribution

# GPG signed
We require all submissions to be signed with a valid GPG key.

Only exception to this rule is the CI/CD bot

## How do I sign with GPG
If you no nothing about GPG keys I really suggest you search on 
[duckduckgo](https://duckduckgo.com) for the best way to do it for the OS you 
are using.

However if you do have a GPG key, add it to you submission profile add at a `-S`
to `git commit -S -m "Some very cool enhancements"` and that's is. You can also 
set this globally or pr git. Do a search on [duckduckgo](https://duckduckgo.com)
to figure out the current way.

# Writing files/lines
- All files most end with a newline (\n)(LF) UTF-8.
- All files have to be in universal UTF-8 style without BOM
- ANy fFiles or file location containing `_windows_` in it's files most be 
  encoded in `ISO-8859-1` Latin1 and newlines *most* end in (CRLF)
- Line length should not be more than 80 chars for terminals support