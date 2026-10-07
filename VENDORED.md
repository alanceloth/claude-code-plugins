# Mods vendorizadas

Cópias fixas de mods de terceiros, auditadas antes de entrar (código lido inteiro, `claude plugin
validate`, sem rodar nada do repo). Fixar a versão aqui evita que um update do autor chegue sem
revisão. Para atualizar: clone o upstream, leia o diff desde o commit abaixo, copie, revalide.

| Mod | Upstream | Commit auditado | Licença | Mudanças locais |
|---|---|---|---|---|
| `agentpane` | https://github.com/xuanji86/claude-agentpane | `17be889` | MIT (Anji Xu) | nenhuma |
| `cc-pr-tracker` | https://github.com/sezaakgun/cc-pr-tracker | `2d96fc7` | MIT (Seza Akgün) | defaults: `notifyClaude=false` (não injeta mensagem na conversa) e `autoWatch="gh pr create only"` (não sai observando qualquer URL de PR citada) |

Avaliada e **recusada**: `md-preview` (hamzafer/claude-code-mods) — envia o texto inteiro de
qualquer `.md` de repo com remote github.com para a API `/markdown` do GitHub, inclusive rascunho
não commitado.

Removida depois de instalada: `ts-band` (hoobnn) — status do Tailscale acima do prompt; sem uso prático no dia a dia (07/10/2026).
