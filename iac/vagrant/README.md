IaC (Vagrant) para as VMs do laboratório DNS

Diretório específico: `iac/vagrant/dns1`

Passos para usar (requer Vagrant + provider, ex: VirtualBox):

1. Instale Vagrant e VirtualBox (ou outro provider suportado).

2. Vá para o diretório da VM:

```bash
cd iac/vagrant/dns1
```

3. Inicie a VM:

```bash
vagrant up
```

4. Acesse por SSH:

```bash
vagrant ssh
```

Observações:

- O provisionamento instala `bind9` e configura uma zona de exemplo `empresa.local` apontando `dns` para `192.168.56.10`.
- Para usar IPs diferentes (ex.: 192.168.1.10), edite o `Vagrantfile` e os registros no arquivo gerado `/etc/bind/db.empresa.local`.
- O conteúdo do repositório é sincronizado em `/vagrant_data` dentro da VM; se desejar usar um arquivo de zona personalizado, coloque-o em `etc/bind/db.empresa.local` no repositório antes de `vagrant up`.
