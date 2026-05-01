#!/usr/bin/env bash
# CCA-F Prep 스킬 제거 스크립트

set -euo pipefail

DEST_DIR="$HOME/.claude/skills"
SKILLS=(learn-agentic-architecture learn-context-engineering learn-claude-code learn-agent-sdk learn-production-deployment learn-meta learn-quiz)

REMOVED=0
for skill in "${SKILLS[@]}"; do
  dest="$DEST_DIR/$skill"
  if [ -L "$dest" ]; then
    rm "$dest"
    echo "- $skill 제거"
    REMOVED=$((REMOVED+1))
  fi
done

echo ""
echo "총 $REMOVED 개 제거됨."
