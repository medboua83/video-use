# Tester video-use sur Ubuntu GitHub Actions

Le workflow **Ubuntu video-use** installe Python 3.12, Node.js 22, FFmpeg,
les dependances du depot et Codex CLI. Il execute les tests du depot et un
veritable rendu de deux extraits synthetiques avant d'ouvrir le SSH.
Ce test ne consomme aucun credit de transcription ou d'agent IA.

## Demarrer

Dans Actions, selectionner **Ubuntu video-use > Run workflow**, cocher
**Ouvrir une session SSH Tailscale** et choisir la duree (300 minutes par
defaut, 330 maximum). Le resume de l'execution indique l'adresse SSH.
La machine disparait en fin de session. Annuler le workflow pour terminer
plus tot ; aucun redemarrage automatique n'est prevu.

Sur un ordinateur connecte au meme compte Tailscale :

```sh
ssh runner@ADRESSE_TAILSCALE
cd /home/runner/work/video-use/video-use
source .venv/bin/activate
```

On peut aussi utiliser la console SSH dans le navigateur Tailscale si elle
est disponible : Machines > video-use-... > SSH, utilisateur `runner`.

## Monter une video

Le moteur FFmpeg fonctionne sans Adobe ni GPU dedie. Pour le montage
conversationnel, lancer `codex` et connecter son compte personnel. Le skill
video-use est enregistre dans `~/.agents/skills/video-use`.
L'authentification de l'application Codex sur ton ordinateur n'est pas
automatiquement copiee dans cette machine temporaire.

La transcription du depot utilise ElevenLabs. Pour entrer la cle sans
l'afficher ni l'inscrire dans l'historique du terminal :

```sh
read -rsp 'Cle ElevenLabs : ' ELEVENLABS_API_KEY; echo
export ELEVENLABS_API_KEY
```

Cette cle n'est pas necessaire pour le test synthetique. La transcription
envoie l'audio a ElevenLabs et peut consommer des credits. Aucun appel IA
ou transcription n'est lance automatiquement par le workflow.

Depuis ton ordinateur, envoyer un fichier avec :

```sh
scp ma-video.mp4 runner@ADRESSE_TAILSCALE:/home/runner/videos/
```

Puis dans la session SSH :

```sh
cd ~/videos
codex
```

Exemple de demande : « Utilise video-use, examine mes prises et propose un
montage de 30 secondes avec sous-titres. »

## Recuperer le resultat

Avant la fin de la session, depuis ton ordinateur :

```sh
scp -r runner@ADRESSE_TAILSCALE:/home/runner/videos/edit ./resultat-video
```

Le workflow publie seulement sa video synthetique dans un artefact conserve
un jour. Il ne sauvegarde pas automatiquement les videos personnelles,
les identifiants ou les resultats de montage. Les journaux et les artefacts
du depot public sont publics : ne pas y afficher de cle ou de contenu prive.

## Acces configure

L'integration Tailscale utilise les secrets GitHub `TS_OAUTH_CLIENT_ID` et
`TS_OAUTH_SECRET`, avec la permission Auth Keys et le tag `tag:video-use`.
La regle SSH autorise uniquement le compte proprietaire configure vers ce
tag comme utilisateur Linux `runner`, avec verification d'identite.
Le compte `runner` dispose de sudo sur cette machine jetable.

Les sessions Actions servent au developpement et aux tests de ce depot.
La machine standard du depot public est gratuite selon les conditions
GitHub ; les services IA restent soumis aux quotas de leurs fournisseurs.
