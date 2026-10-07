# Mods vendorizadas

Cópias fixas de mods de terceiros, auditadas antes de entrar (código lido inteiro, `claude plugin
validate`, sem rodar nada do repo). Fixar a versão aqui evita que um update do autor chegue sem
revisão. Para atualizar: clone o upstream, leia o diff desde o commit abaixo, copie, revalide.

| Mod | Upstream | Commit auditado | Licença | Mudanças locais |
|---|---|---|---|---|
| `agentpane` | https://github.com/xuanji86/claude-agentpane | `17be889` | MIT (Anji Xu) | nenhuma |
| `cc-pr-tracker` | https://github.com/sezaakgun/cc-pr-tracker | `2d96fc7` | MIT (Seza Akgün) | defaults: `notifyClaude=false` (não injeta mensagem na conversa) e `autoWatch="gh pr create only"` (não sai observando qualquer URL de PR citada) |
| `ts-band` | https://github.com/hoobnn/hoobnn-agent-mods (`claude-code/ts-band`) | `b95d1e4` | MIT (hoobnn) | nenhuma; `LICENSE` copiado da raiz do upstream |

Avaliada e **recusada**: `md-preview` (hamzafer/claude-code-mods) — envia o texto inteiro de
qualquer `.md` de repo com remote github.com para a API `/markdown` do GitHub, inclusive rascunho
não commitado.
