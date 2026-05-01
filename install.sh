#!/usr/bin/env bash
# CCA-F Prep 스킬 설치 스크립트
# 7개 스킬을 ~/.claude/skills/ 에 심볼릭 링크로 등록한다.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_DIR/.agents/skills"
DEST_DIR="$HOME/.claude/skills"

SKILLS=(learn-agentic-architecture-orchestration learn-tool-design-mcp-integration learn-claude-code-configuration-workflows learn-prompt-engineering-structured-output learn-context-management-reliability learn-meta learn-quiz)

echo "═══════════════════════════════════════════════"
echo "  CCA-F Prep 설치 (공식 PDF Version 0.1 기준)"
echo "═══════════════════════════════════════════════"
echo "  Source : $SRC_DIR"
echo "  Target : $DEST_DIR"
echo ""

if [ ! -d "$SRC_DIR" ]; then
  echo "✗ 스킬 소스 폴더가 없습니다: $SRC_DIR"
  exit 1
fi

mkdir -p "$DEST_DIR"

INSTALLED=0
SKIPPED=0
REPLACED=0

for skill in "${SKILLS[@]}"; do
  src="$SRC_DIR/$skill"
  dest="$DEST_DIR/$skill"

  if [ ! -d "$src" ]; then
    echo "✗ $skill — 소스 없음, 건너뜀"
    SKIPPED=$((SKIPPED+1))
    continue
  fi

  if [ -L "$dest" ]; then
    current_target="$(readlink "$dest")"
    if [ "$current_target" = "$src" ]; then
      echo "✓ $skill — 이미 설치됨"
      INSTALLED=$((INSTALLED+1))
      continue
    fi
    rm "$dest"
    ln -s "$src" "$dest"
    echo "↻ $skill — 링크 갱신"
    REPLACED=$((REPLACED+1))
  elif [ -e "$dest" ]; then
    echo "⚠ $skill — 같은 이름의 실제 디렉토리/파일 존재. 건너뜀."
    echo "   직접 확인: $dest"
    SKIPPED=$((SKIPPED+1))
  else
    ln -s "$src" "$dest"
    echo "+ $skill — 설치 완료"
    INSTALLED=$((INSTALLED+1))
  fi
done

echo ""
echo "═══════════════════════════════════════════════"
echo "  설치: $INSTALLED  /  갱신: $REPLACED  /  스킵: $SKIPPED"
echo "═══════════════════════════════════════════════"
echo ""
echo "Claude Code에서 다음 명령으로 시작하세요:"
echo ""
echo "  /learn-meta                                       — 시험 메타·함정·전략 (먼저 권장)"
echo "  /learn-agentic-architecture-orchestration         — D1 (27%) Tasks 1.1~1.7"
echo "  /learn-tool-design-mcp-integration                — D2 (18%) Tasks 2.1~2.5"
echo "  /learn-claude-code-configuration-workflows        — D3 (20%) Tasks 3.1~3.6"
echo "  /learn-prompt-engineering-structured-output       — D4 (20%) Tasks 4.1~4.6"
echo "  /learn-context-management-reliability             — D5 (15%) Tasks 5.1~5.6"
echo "  /learn-quiz                                       — 모의고사 (4 모드: Quick5/Mini15/Half30/Full60)"
echo ""
echo "권장 순서: meta → D1 → D3 → D4 → D2 → D5 → quiz"
echo ""
echo "이미 이전 버전이 설치되어 있다면, 옛 슬래시명 7개를 수동 제거 후 재실행:"
echo "  rm $DEST_DIR/learn-agentic-architecture"
echo "  rm $DEST_DIR/learn-context-engineering"
echo "  rm $DEST_DIR/learn-claude-code"
echo "  rm $DEST_DIR/learn-agent-sdk"
echo "  rm $DEST_DIR/learn-production-deployment"
