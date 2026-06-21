Agente Especialista em Redes — Uso

Arquivos criados:
- agents/agente-redes.agent.md
- prompts/agente-redes.prompt.md
- skills/network-skills.md

Como usar (sugestão):
1. Abra o Copilot Chat e carregue o repositório `projeto-redes`.
2. Pergunte ao agente algo específico, por exemplo: "Por que `dns1` não responde consultas?".
3. O agente irá ler `dns-server.md` e `VMs/` automaticamente e sugerir comandos.

Exemplos de prompt para o usuário:
- "Analise `dns-server.md` e proponha um plano para configurar delegação de zona."
- "Me guie para coletar informações de diagnóstico da VM `dns2`."

Precauções:
- O agente sugere comandos; execute-os no seu terminal local.
- Para mudanças com impacto, peça confirmação antes de aplicar qualquer alteração.

Quer que eu adicione um fluxo de execução automatizado (script de diagnóstico) ou registre este agente na interface de VS Code? Responda e eu prossigo.