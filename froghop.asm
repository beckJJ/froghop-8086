; Porto alegre, maio de 2021
; Trabalho do INTEL
;
;====================================================================
;====================================================================

	.model		small
	.stack
		
CR		equ		0dh
LF		equ		0ah

	.data
	
; Mensagens
linha0	db	'Arquitetura e Organizacao de Computadores I', 0
linha1	db	'Trabalho do INTEL - 2020/2', 0
linha2	db	'Pedro Company Beck - Cartao 00324055', 0

jogoL0	db	'+--1--2--3--4--5--6--7--+', 0
jogoL1	db	'|                       |', 0
jogoL2	db	'+-----------------------+', 0

menu0 	db 	'1-7 movimentacao de pecas', 0
menu1 	db 	'Z - Recomecar o jogo', 0
menu2 	db 	'R - Ler arquivo de jogo', 0
menu3 	db 	'G - Gravar arquivo de jogo', 0
menu4	db	'X - Sair do jogo',0

msg_w	db	'Voce VENCEU o jogo.', 0
msg_l	db	'Voce PERDEU o jogo.', 0
clear	db	'                                                                               ', 0
mov_i	db	'Movimento Invalido!', 0
exit	db	'Sair do jogo? (S/N)', 0
teste	db	'Teste', 0
                                                                               
MsgPedeArquivo		db	"Nome do arquivo: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", 0
MsgCRLF				db	CR, LF, 0
MsgIgual			db	" = ", 0

Contador		dw		26 dup (?)	; A=0, B=1, ..., Z=25

; Vari疱el interna usada na rotina printf_w
BufferWRWORD	db		10 dup (?)

; Variaveis para uso interno na fun鈬o sprintf_w
sw_n	dw	0
sw_f	db	0
sw_m	dw	0

; Vetor de peças do jogo, com 0 representando ausência de peças,
; 1 representando azul e 2 representando vermelho
err_b	dw	0ffffh, 0ffffh, 0ffffh	; "Paredes" do tabuleiro
pecas	dw	1,1,1,0,2,2,2			; Tabuleiro
err_e	dw	0ffffh, 0ffffh, 0ffffh	; "Paredes" do tabuleiro
str_p	db	'A  A  A  .  V  V  V ', 0	; String com as pecas do tabuleiro
temp_8	db	0
temp_16	dw	0
flag_fim	dw	0	; flag fim de jogo
tempval	db	0
posA	dw	0
posC	dw	0
str_f	db	0, 0, 0, 0, 0, 0, 0, 0

FileName		db		256 dup (?)		; Nome do arquivo a ser lido
FileBuffer		db		10 dup (?)		; Buffer de leitura do arquivo
FileHandle		dw		0				; Handler do arquivo
FileNameBuffer	db		150 dup (?)
caractere		db		0


MAXSTRING	equ		200
String	db		MAXSTRING dup (?)		; Usado na funcao gets

; Variáveis para funções de replay
cont_s	dw	0
cont_f	dw	0
cont_p	dw	0
cont_m	dw	0
flag_replay	dw	0	; flag de replay
flag_write	dw	0	; flag de gravação
; menu do replay
menuA0	db	'N - Proximo movimento', 0
menuA1	db	'Outras teclas - encerra leitura', 0
str_m	db	128	dup	(?)	; Guardar os movimentos realizados no arquivo aqui
c_mov	db	'[ _ ]', 0	; mostrar o movimento na tela
clear2	db	'     ', 0

; menu de gravação
menuB0	db	'ESC - encerrar a gravacao', 0
exit_g	db	'Sair da gravacao? (S/N)', 0

FileNameSrc		db		256 dup (?)		; Nome do arquivo a ser lido
FileNameDst		db		256 dup (?)		; Nome do arquivo a ser escrito
FileHandleSrc	dw		0				; Handler do arquivo origem
FileHandleDst	dw		0				; Handler do arquivo destino

MsgPedeArquivoSrc	db	"Nome do arquivo origem: ", 0
MsgPedeArquivoDst	db	"Nome do arquivo destino: ", 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", 0
; cópia do tabuleiro
		dw	0ffffh, 0ffffh, 0ffffh	; "Paredes" do tabuleiro
pecas_i	dw	0,0,0,0,0,0,0			; Tabuleiro
		dw	0ffffh, 0ffffh, 0ffffh	; "Paredes" do tabuleiro


	.code
	.startup

	call	clearScreen
	; Imprimir dados
	mov		dh,0
	mov		dl,19
	call	SetCursor
	lea		bx,linha0
	call	printf_s

	mov		dh,1
	mov		dl,27
	call	SetCursor	
	lea		bx,linha1
	call	printf_s
	
	mov		dh,2
	mov 	dl,22
	call 	SetCursor
	lea		bx,linha2
	call	printf_s
inicio:
	mov		flag_fim,0
	mov		flag_replay,0
	; imprimir jogo
	mov 	dh,7
	mov 	dl,27
	call 	SetCursor
	lea		bx,jogoL0
	call 	printf_s
	
	mov 	dh,8
	mov 	dl,27
	call 	SetCursor
	lea		bx,jogoL1
	call 	printf_s
	
	mov 	dh,9
	mov 	dl,27
	call 	SetCursor
	lea		bx,jogoL1
	call 	printf_s
	
	mov 	dh,10
	mov 	dl,27
	call 	SetCursor
	lea		bx,jogoL1
	call 	printf_s
	
	mov 	dh,11
	mov 	dl,27
	call 	SetCursor
	lea		bx,jogoL2
	call 	printf_s
	
	; imprimir menu
	mov		dh,18
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu0
	call 	printf_s

	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu1
	call 	printf_s

	mov		dh,20
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu2
	call 	printf_s
	
	mov		dh,21
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu3	
	call 	printf_s
	
	mov		dh,22
	mov		dl,0
	call	SetCursor
	lea		bx,menu4
	call	printf_s

	mov		dh,9
	mov 	dl,30
	call 	SetCursor
	lea		bx,str_p
	call	printf_s

	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor

recebe_tecla:
	cmp		flag_replay,1
	je		replay
	cmp		flag_write,1
	je		gravacao

	call	getKey
nao_sair:
	mov		temp_8,al
	;limpar a última linha
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor

	cmp		flag_fim,1
	jne		nao_pula_num
	cmp		flag_write,1
	jne		nao_pula_num
	mov		al,temp_8
	jmp		volta

nao_pula_num:
	mov		al,temp_8
	; Verifica qual tecla o usuario apertou em al e chama as funcoes
	cmp		al,'1'
	jae		teste_num

	cmp		flag_replay,1	; se estiver com flag de replay, pular os testes
	je		teste_fim

	cmp		flag_write,1	; se estiver com flag de gravação, pular os testes
	je		recebe_tecla
volta:
	; reset
	cmp 	al,'z'
	je		reset_game
	cmp		al,'Z'
	je 		reset_game ; comparar com 'z' e 'Z'
	; read
	cmp		al,'r'
	je 		read_game
	cmp		al,'R'
	je		read_game
	; write
	cmp		al,'g'
	je		write_game
	cmp		al,'G'
	je		write_game
	cmp		al,'X'
	je		fim
	cmp		al,'x'
	je		fim
	; verificar se o usuario ganhou ou perdeu
	jmp		teste_fim
fim:
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,exit
	call	printf_s
sair:
	call	getKey
	cmp		al,'S'
	je		fim2
	cmp		al,'s'
	je		fim2
	cmp		al,'N'
	je		nao_sair
	cmp		al,'n'
	je		nao_sair
	jmp		sair

fim2:
	call	clearScreen
	.exit	0

; =========================================================================== ;
replay:
	; apagar menu
	mov		dh,18
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,20
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,21
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,22
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	; imprimir novo menu
	mov		dh,18
	mov 	dl,0
	call 	SetCursor
	lea		bx,menuA0
	call	printf_s
	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea		bx,menuA1
	call	printf_s
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor

	mov		bx,cont_m		; ~0x604:0x213
	lea		ax,str_m[bx]	; carrega o endereço da string de movimentos
	mov		bx,ax
	mov		ah,byte ptr [bx]
	cmp		ah,0	; verifica se está no fim da string
	je		fim_replay
;	cmp		flag_fim,1	; verifica se o jogo já acabou
;	je		fim_replay
	mov		temp_8,ah

	call	getKey
	cmp		al,'N'
	je		nao_sair_replay
	cmp		al,'n'
	je		nao_sair_replay
	jmp		sair_replay
nao_sair_replay:
	mov		al,temp_8
	; imprimir o movimento a ser jogado
	lea		bx,c_mov+2
	mov		byte ptr [bx], al
	mov		dh,9
	mov 	dl,19
	call 	SetCursor
	lea		bx,c_mov
	call	printf_s
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	mov		al,temp_8
	inc		cont_m
	jmp		nao_sair	; pular o getKey

fim_replay:
	call	getKey
sair_replay:
	mov		dh,9
	mov 	dl,19
	call 	SetCursor
	lea		bx,clear2
	call	printf_s
	; limpar menu
	mov		dh,18
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	; imprimir menu antigo
	mov		dh,18
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu0
	call 	printf_s

	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu1
	call 	printf_s

	mov		dh,20
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu2
	call 	printf_s
	
	mov		dh,21
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu3	
	call 	printf_s
	
	mov		dh,22
	mov		dl,0
	call	SetCursor
	lea		bx,menu4
	call	printf_s

	mov		dh,9
	mov 	dl,30
	call 	SetCursor
	lea		bx,str_p
	call	printf_s

	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	; limpar flag de replay
	mov		flag_replay,0
	mov		cont_m,0
	; voltar pro getkey
	jmp		recebe_tecla
; =========================================================================== ;
gravacao:
	; apagar menu
	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,20
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,21
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,22
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	; imprimir novo menu
	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea		bx,menuB0
	call	printf_s
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor

;	cmp		flag_fim,1	; verifica se o jogo já acabou
;	je		fim_gravacao

	call	getKey
	cmp		al,27	; ESC
	je		confirmar
	jmp		nao_sair_gravacao

confirmar:
	lea		bx,exit_g
	call	printf_s
confirmar2:
	call	getKey
	cmp		al,'S'
	je		sair_gravacao
	cmp		al,'s'
	je		sair_gravacao
	cmp		al,'N'
	je		nao_sair_gravacao
	cmp		al,'n'
	je		nao_sair_gravacao
	jmp		confirmar2
	

nao_sair_gravacao:
	jmp		nao_sair	; pular o getKey

fim_gravacao:
	call	getKey
sair_gravacao:
	; limpar menu
	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	; imprimir menu antigo
	mov		dh,19
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu1
	call 	printf_s

	mov		dh,20
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu2
	call 	printf_s
	
	mov		dh,21
	mov 	dl,0
	call 	SetCursor
	lea 	bx,menu3	
	call 	printf_s
	
	mov		dh,22
	mov		dl,0
	call	SetCursor
	lea		bx,menu4
	call	printf_s

	mov		dh,9
	mov 	dl,30
	call 	SetCursor
	lea		bx,str_p
	call	printf_s

	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	; limpar flag de gravação
	mov		flag_write,0
	; colocar um 0 depois da string
	mov		bx,cont_m
	lea		bx,str_m[bx]
	mov		byte ptr [bx],'0'
	mov		cont_m,0
	; chamar a função para gravar
	jmp		write_file

; =========================================================================== ;
teste_num:
	cmp 	al,'7'
	jbe 	numeros
	jmp		volta
	; printa a tecla apertada	
	call	clearScreen
	
numeros:
	; receber a peça que está na posição informada
	mov		tempval,al	; salva o valor de al em tempval
	and		ax,0007h	
	mov		posA,ax
	shl		ax,1
;	sub		ax,2		; ~0x604:0x124
	mov		bx,ax
	lea		bx,pecas[bx-2]
	mov		bx,[bx]
	; se for uma peça azul
	cmp		bx,1
	je		blue
	; se for uma peça vermelha
	cmp 	bx,2
	je		red
	; se estiver vazia, ou com algum valor incorreto, voltar para recebe_tecla
	; (e depois salvar essa jogada)
	jmp		input_invalido

blue: 
	; verificar a próxima peça
	mov		ax,posA
	mov		cx,ax	; ~0x605:0x13B
	inc		cx
	mov		posC,cx
	shl		cx,1
	mov		bx,cx
	lea		bx,pecas[bx-2]
	mov		bx,[bx]
	; se a próxima peça também for azul
	cmp		bx,1
	je		input_invalido
	; se a próxima peça estiver vazia
	cmp		bx,0
	jne		b_red
	mov		cx,posC
	shl		cx,1
	mov		ax,posA
	shl		ax,1
	mov		bx,cx
	lea		bx,pecas[bx-2]
	mov		[bx],1	; move a peça para frente
	mov		bx,ax
	lea		bx,pecas[bx-2]
	mov		[bx],0
	jmp		print_pecas		; imprime o tabuleiro atualizado
	; se a próxima peça for vermelha
b_red:
	cmp		bx,2
	jne		input_invalido
	mov		bx,posC		; posC tem pos+1
	add		bx,1		; pos+2
	mov		posC,bx
	shl		bx,1
	lea		bx,pecas[bx-2]
	cmp		[bx],0
	jne		input_invalido	; se não estiver
	mov		[bx],1
	mov		bx,posA
	shl		bx,1
	lea		bx,pecas[bx-2]
	mov		[bx],0
	jmp		print_pecas		; imprime o tabuleiro atualizado

red:
	; verificar a peça anterior
	mov		ax,posA
	mov		cx,ax	; ~0x605:0x13B
	dec		cx
	mov		posC,cx
	shl		cx,1
	mov		bx,cx
	lea		bx,pecas[bx-2]
	mov		bx,[bx]
	; se a peça anterior também for vermelha
	cmp		bx,2
	je		input_invalido
	; se a peça anterior estiver vazia
	cmp		bx,0
	jne		r_blue
	; teste para ver se essa peça é a primeira peça
	mov		cx,posC
	shl		cx,1
	mov		ax,posA
	shl		ax,1
	mov		bx,cx
	lea		bx,pecas[bx-2]
	mov		[bx],2	; move a peça para trás
	mov		bx,ax
	lea		bx,pecas[bx-2]
	mov		[bx],0
	jmp		print_pecas		; imprime o tabuleiro atualizado

	; se a peça anterior for azul
r_blue:
	cmp		bx,1
	jne		input_invalido
	mov		bx,posC		; posC tem pos-1
	sub		bx,1		; pos-2
	mov		posC,bx
	shl		bx,1
	lea		bx,pecas[bx-2]
	cmp		[bx],0
	jne		input_invalido	; se não estiver
	mov		[bx],2
	mov		bx,posA
	shl		bx,1
	lea		bx,pecas[bx-2]
	mov		[bx],0
	jmp		print_pecas		; imprime o tabuleiro atualizado

; =========================================================================== ;
print_pecas: ; 0604:020D
	mov		ax,posA
	dec		ax
	add		ax,ax
	add		ax,posA
	dec		ax
	mov		bx,ax
	lea		bx,str_p[bx]
	mov		[bx],' .'

	mov		bx,posC
	shl		bx,1
	lea		bx,pecas[bx-2]
	mov		bx,[bx]
	cmp		bx,1
	je		print_blue
	cmp		bx,2
	je		print_red
volta_print:
	mov		dh,9
	mov 	dl,30
	call 	SetCursor
	lea		bx,str_p
	call	printf_s
	mov		ax,0
	mov 	dh,24
	mov 	dl,0
	cmp		flag_write,1	; se estiver gravando
	je		gravar_movimento
	call 	SetCursor
	jmp		volta

print_blue:
	mov		cx,posC
	dec		cx
	add		cx,cx
	add		cx,posC
	dec		cx
	mov		bx,cx
	lea		bx,str_p[bx]
	mov		[bx],' A'
	jmp		volta_print
print_red:
	mov		cx,posC
	dec		cx
	add		cx,cx
	add		cx,posC
	dec		cx
	mov		bx,cx
	lea		bx,str_p[bx]
	mov		[bx],' V'
	jmp		volta_print
; =========================================================================== ;

reset_game:
	; Resetar o array de peças
	lea		bx,pecas
	mov		[bx],1
	add		bx,2
	mov		[bx],1
	add		bx,2
	mov		[bx],1
	add		bx,2
	mov		[bx],0
	add		bx,2
	mov		[bx],2
	add		bx,2
	mov		[bx],2
	add		bx,2
	mov		[bx],2
	; Resetar a string de peças para 'A  A  A  .  V  V  V '
	lea		bx,str_p-1
	mov		[bx],'A '
	add		bx,4
	mov		[bx],' A'
	add		bx,2
	mov		[bx],'A '
	add		bx,4
	mov		[bx],' .'
	add		bx,2
	mov		[bx],'V '
	add		bx,4
	mov		[bx],' V'
	add		bx,2
	mov		[bx],'V '
	; Posicionar cursor
	mov		dh,9
	mov 	dl,30
	call 	SetCursor
	lea		bx,str_p
	call	printf_s
	jmp		inicio
; =========================================================================== ;

teste_fim:
	lea		bx,pecas
	cmp		[bx],2
	jne		teste_perdeu
	add		bx,2
	cmp		[bx],2
	jne		teste_perdeu
	add		bx,2
	cmp		[bx],2
	jne		teste_perdeu
	add		bx,2
	cmp		[bx],0
	jne		teste_perdeu
	add		bx,2
	cmp		[bx],1
	jne		teste_perdeu
	add		bx,2
	cmp		[bx],1
	jne		teste_perdeu
	add		bx,2
	cmp		[bx],1
	jne		teste_perdeu

	mov		flag_fim, 1	; aciona flag de fim
	; Imprimir mensagem de vitoria
	mov		dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,msg_w
	call	printf_s
	jmp		recebe_tecla

teste_perdeu:
	lea		bx,pecas
	cmp		[bx],0
	je		zero_encontrado
	add		bx,2
	cmp		[bx],0
	je		zero_encontrado
	add		bx,2
	cmp		[bx],0
	je		zero_encontrado
	add		bx,2
	cmp		[bx],0
	je		zero_encontrado
	add		bx,2
	cmp		[bx],0
	je		zero_encontrado
	add		bx,2
	cmp		[bx],0
	je		zero_encontrado
	add		bx,2
	cmp		[bx],0
	je		zero_encontrado
	call	f_teste
	jmp		recebe_tecla

zero_encontrado:
	mov		temp_16,bx	; guardar add do 0
	;verificar se as 2 casas anteriores são 2 e as proximas duas casas sao 1
	sub		bx,2
	cmp		[bx],0ffffh ; verificar se é fora do vetor
	je		test_a
	cmp		[bx],2
	jne		test_v
	sub		bx,2
	cmp		[bx],0ffffh	; verificar se é fora do vetor
	je		test_a
	cmp		[bx],2
	je		test_a
	jmp		test_v
test_a:
	mov		bx,temp_16
	add		bx,2
	cmp		[bx],0ffffh	; verificar se é fora do vetor
	je		test_a2
	cmp		[bx],1
	je		test_a2
	jmp		test_v
test_a2:
	add		bx,2
	cmp		[bx],0ffffh	; verificar se é fora do vetor
	je		derrota
	cmp		[bx],1
	je		derrota
;	call	f_teste
	jmp		test_v
	; se as duas casas forem azuis, imprimir mensagem de derrota
derrota:
	mov		flag_fim, 1	; aciona flag fim
	mov		dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,msg_l
	call	printf_s
	jmp		recebe_tecla

test_v:
	;verificar se as 2 proximas casas são 1 e as duas casas anteriores sao 2
	mov		bx,temp_16
	cmp		[bx],0ffffh	; verificar se é fora do vetor
	je		test_v2
	add		bx,2
	cmp		[bx],1
	jne		recebe_tecla	; não acabou ainda
	add		bx,2
	cmp		[bx],0ffffh	; verificar se é fora do vetor
	je		test_v2
	cmp		[bx],1
	je		test_v2
	jmp		recebe_tecla	; não acabou ainda

test_v2:
	mov		bx,temp_16
	sub		bx,2
	cmp		[bx],2
	jne		recebe_tecla	; não acabou ainda
	sub		bx,2
	cmp		[bx],2
	jne		recebe_tecla	; não acabou ainda
	jmp		derrota

; =========================================================================== ;
; =========================================================================== ;
; =========================================================================== ;
read_game:
	call	GetFileName
	mov		dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,24
	mov 	dl,0
	call 	SetCursor

	mov		al,0
	lea		dx,FileName
	mov		ah,3dh
	int		21h
	jnc		Continua1
	lea		bx,MsgErroOpenFile
	call	printf_s
	mov		al,1
	jmp		recebe_tecla

Continua1:
	mov		FileHandle,ax
Again:
	mov		bx,FileHandle
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	jnc		Continua2		
	lea		bx,MsgErroReadFile
	call	printf_s
	mov		al,1
	jmp		CloseAndFinal
Continua2:
	cmp		ax,0
	jne		Continua3
	mov		al,0
	jmp		CloseAndFinal
Continua3:
	; Depois de ler cada caractere do arquivo, desenhar o tabuleiro baseado nos
	; primeiros 7 caracteres (até o CRLF)
	; Usar a 2a linha (depois do CRLF) para mandar os comandos pro jogo
	; (colocar no registrador al, usando flag de read)
	mov		bl,FileBuffer
	cmp		bl,'A'
	je		p_jogo
	cmp		bl,'x'
	je		p_jogo
	cmp		bl,'V'
	je		p_jogo
	cmp		bl,'1'
	jae		tst_num2
	cmp		bl,'0'
	je		CloseAndFinal	; se for encontrado algum zero
	jmp		again
tst_num2:
	cmp		bl,'7'
	jbe		mov_jogo
	jmp		again
CloseAndFinal:
	; Mudar a str_p com o que foi lido em str_f
	mov		bx,cont_f		; ~0x604:0x7D5
	lea		ax,str_f[bx]	; carrega o endereço da string lida
	sub		ax,8			; ???

	mov		bx,cont_s
	lea		di,str_p[bx]	; carrega o endereço da string a ser modificada

	mov		bx,ax
	mov		ax,[bx]
	cmp		ah,0	; verifica se está no fim da string
	je		prox
	cmp		ah,'A'
	je		p_a
	cmp		ah,'x'
	je		p_x
	cmp		ah,'V'
	je		p_v
	jmp		incrementar

p_a:
	mov		bx,cont_p
	lea		bx,pecas[bx]
	mov		[bx],1
	jmp		incrementar
p_x:
	mov		bx,cont_p
	lea		bx,pecas[bx]
	mov		[bx],0
	mov		ah,'.'
	jmp		incrementar
p_v:
	mov		bx,cont_p
	lea		bx,pecas[bx]
	mov		[bx],2
	jmp		incrementar

incrementar:
	mov		byte ptr es:[di],ah	; muda a string
	inc		cont_f
	add		cont_p,2
	add		cont_s,3
	jmp		CloseAndFinal

prox:
	mov		dh,9
	mov 	dl,30
	call 	SetCursor
	lea		bx,str_p
	call	printf_s
	mov		ax,0
	mov 	dh,24
	mov 	dl,0
	call 	SetCursor
	; colocar um 0 no fim da string de movimentos
	mov		bx,cont_m
	lea		bx,str_m[bx]
	mov		[bx],0
	; zerar contadores
	mov		cont_m,0
	mov		cont_f,0
	mov		cont_s,0
	mov		cont_p,0
	mov		flag_fim,0
	; executar o replay
	mov		flag_replay,1
	jmp		recebe_tecla

p_jogo: ; salvar as peças do jogo ~0x604:0x557
	mov		temp_8,bl
	mov		bx,cont_f
	lea		di,str_f[bx]	; carregar o endereço da string
	mov		bl,temp_8
	mov		byte ptr es:[di],bl	; guarda o caractere na string
	inc		cont_f
	jmp		again

mov_jogo:	; salvar os movimentos do jogo
	mov		temp_8,bl
	mov		bx,cont_m
	lea		di,str_m[bx]
	mov		bl,temp_8
	mov		byte ptr es:[di],bl
	inc		cont_m
	jmp		again
; =========================================================================== ;
; =========================================================================== ;
; =========================================================================== ;
write_game:
	mov		flag_write,1	; aciona flag de gravação
	call	GetFileNameDst
	; salvar posição inicial das peças
	lea		bx,pecas
	lea		di,pecas_i
	mov		ax,[bx]
	mov		word ptr es:[di], ax
	add		bx,2
	add		di,2
	mov		ax,[bx]
	mov		word ptr es:[di], ax
	add		bx,2
	add		di,2
	mov		ax,[bx]
	mov		word ptr es:[di], ax
	add		bx,2
	add		di,2
	mov		ax,[bx]
	mov		word ptr es:[di], ax
	add		bx,2
	add		di,2
	mov		ax,[bx]
	mov		word ptr es:[di], ax
	add		bx,2
	add		di,2
	mov		ax,[bx]
	mov		word ptr es:[di], ax
	add		bx,2
	add		di,2
	mov		ax,[bx]
	mov		word ptr es:[di], ax

gravando:
	mov		dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,clear
	call	printf_s
	mov		dh,24
	mov 	dl,0
	call 	SetCursor

	jmp		recebe_tecla

gravar_movimento:
	; pegar o valor em tempval
	mov		al, tempval
	; guardar na string de movimentos
	mov		bx, cont_m
	lea		di, str_m[bx]
	mov		al, tempval
	mov		byte ptr es:[di],al
	inc		cont_m
	jmp		recebe_tecla

write_file:
	lea		dx,FileNameDst
	call	fcreate
	mov		FileHandleDst,bx
	jnc		copia_p
	mov		bx,FileHandleSrc
	call	fclose
	lea		bx, MsgErroCreateFile
	call	printf_s
	jmp		recebe_tecla
	;copiar peças
copia_p:
	mov		bx,cont_p
	lea		bx,pecas_i[bx]
	mov		dl, byte ptr [bx]
	cmp		dl,1
	je		copia_A
	cmp		dl,2
	je		copia_V
	cmp		dl,0
	je		copia_x
	jmp		ins_crlf

copia_A:
	mov		dl,'A'
	mov		bx,FileHandleDst
	call	setChar
	add		cont_p,2
	jmp		copia_p

copia_V:
	mov		dl,'V'
	mov		bx,FileHandleDst
	call	setChar
	add		cont_p,2
	jmp		copia_p

copia_x:
	mov		dl,'x'
	mov		bx,FileHandleDst
	call	setChar
	add		cont_p,2
	jmp		copia_p

ins_crlf:
	; inserir CRLF
	mov		dl,CR
	mov		bx,FileHandleDst
	call	setChar
	mov		dl,LF
	mov		bx,FileHandleDst
	call	setChar

copia_str:
	mov		bx,cont_m
	lea		bx,str_m[bx]
	mov		dl, byte ptr [bx]
	cmp		dl,'0'
	je		fim_str
	mov		bx,FileHandleDst
	inc		cont_m
	call	setChar
	jnc		copia_str

	lea		bx, MsgErroWriteFile
	call	printf_s
	mov		dl,'0'				; coloca um 0 no final
	mov		bx,FileHandleDst
	call	setChar
	mov		bx,FileHandleDst		; Fecha arquivo destino
	call	fclose
	mov		cont_m,0
	jmp		recebe_tecla

fim_str:
	mov		dl,'0'				; coloca um 0 no final
	mov		bx,FileHandleDst
	call	setChar
	mov		bx,FileHandleDst	; Fecha arquivo destino
	call	fclose
	mov		cont_m,0
	mov		cont_f,0
	mov		cont_s,0
	mov		cont_p,0	
	jmp		recebe_tecla

; =========================================================================== ;
; =========================================================================== ;
; =========================================================================== ;
input_invalido:
	mov		dh,24
	mov 	dl,0
	call 	SetCursor
	lea		bx,mov_i
	call	printf_s
	cmp		flag_write,1	; se estiver gravando
	je		gravar_movimento
	jmp		recebe_tecla

; =========================================================================== ;
; =========================================================================== ;
; =========================================================================== ;
; funcao para testes
f_teste	proc	near
	mov		dh,0
	mov 	dl,0
	call 	SetCursor
	lea		bx,teste
	call	printf_s
	ret
f_teste	endp

; =========================================================================== ;
; ===================== Funções dos professores abaixo ====================== ;
; =========================================================================== ;
;====================================================================
; A partir daqui, est縊 as fun鋏es j・desenvolvidas
;	1) printf_s
;	2) printf_w
;	3) sprintf_w
;====================================================================
	
;--------------------------------------------------------------------
;Fun鈬o Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp

;
;--------------------------------------------------------------------
;Fun鈬o: Escreve o valor de AX na tela
;		printf("%
;--------------------------------------------------------------------
printf_w	proc	near
	; sprintf_w(AX, BufferWRWORD)
	lea		bx,BufferWRWORD
	call	sprintf_w
	
	; printf_s(BufferWRWORD)
	lea		bx,BufferWRWORD
	call	printf_s
	
	ret
printf_w	endp

;
;--------------------------------------------------------------------
;Fun鈬o: Converte um inteiro (n) para (string)
;		 sprintf(string->BX, "%d", n->AX)
;--------------------------------------------------------------------
sprintf_w	proc	near
	mov		sw_n,ax
	mov		cx,5
	mov		sw_m,10000
	mov		sw_f,0
	
sw_do:
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
	mov		sw_n,dx
	
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
	dec		cx
	cmp		cx,0
	jnz		sw_do

	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:

	mov		byte ptr[bx],0
	ret		
sprintf_w	endp



;--------------------------------------------------------------------
;Fun鈬o: posiciona o cursor
;	mov		dh,linha
;	mov		dl,coluna
;	call	SetCursor
;MS-DOS
;	AH = 02h
;	BH = page number
;		0-3 in modes 2&3
;		0-7 in modes 0&1
;		0 in graphics modes
;	DH = row (00h is top)
;	DL = column (00h is left)
;--------------------------------------------------------------------
SetCursor	proc	near
	mov	ah,2
	mov	bh,0
	int	10h
	ret
SetCursor	endp



;--------------------------------------------------------------------
;Fun鈬o: Limpa a tela e coloca no formato texto 80x25
;--------------------------------------------------------------------
clearScreen	proc	near
	mov	ah,0	; Seta modo da tela
	mov	al,7	; Text mode, monochrome, 80x25.
	int	10h
	ret
clearScreen	endp


;--------------------------------------------------------------------
;Fun鈬o: Espera por um caractere do teclado
;Sai: AL => caractere lido do teclado
;Obs:
;	al = Int21(7)
;--------------------------------------------------------------------
getKey	proc	near
	mov		ah,7
	int		21H
	ret
getKey	endp

;--------------------------------------------------------------------
;Funcao: Le o nome do arquivo do teclado
;--------------------------------------------------------------------
GetFileName	proc	near
	lea		bx,MsgPedeArquivo			; Coloca mensagem que pede o nome do arquivo
	call	printf_s

	mov		ah,0ah						; L・uma linha do teclado
	lea		dx,FileNameBuffer
	mov		byte ptr FileNameBuffer,100
	int		21h

	lea		si,FileNameBuffer+2			; Copia do buffer de teclado para o FileName
	lea		di,FileName
	mov		cl,FileNameBuffer+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0			; Coloca marca de fim de string
	ret
GetFileName	endp

;--------------------------------------------------------------------
;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de origem salva-o em FileNameSrc
;--------------------------------------------------------------------
GetFileNameSrc	proc	near
	;printf("Nome do arquivo origem: ")
	lea		bx, MsgPedeArquivoSrc
	call	printf_s

	;gets(FileNameSrc);
	lea		bx, FileNameSrc
	call	gets
	
	ret
GetFileNameSrc	endp


;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de destino salva-o em FileNameDst
;--------------------------------------------------------------------
GetFileNameDst	proc	near
	;printf("Nome do arquivo destino: ");
	lea		bx, MsgPedeArquivoDst
	call	printf_s
	
	;gets(FileNameDst);
	lea		bx, FileNameDst
	call	gets

	ret
GetFileNameDst	endp

;--------------------------------------------------------------------
;Fun鈬o	Abre o arquivo cujo nome est・no string apontado por DX
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	mov		bx,ax
	ret
fopen	endp

;--------------------------------------------------------------------
;Fun鈬o Cria o arquivo cujo nome est・no string apontado por DX
;		boolean fcreate(char *FileName -> DX)
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	mov		bx,ax
	ret
fcreate	endp

;--------------------------------------------------------------------
;Entra:	BX -> file handle
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
;Fun鈬o	Le um caractere do arquivo identificado pelo HANLDE BX
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------
getChar	proc	near
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	mov		dl,FileBuffer
	ret
getChar	endp
		
;--------------------------------------------------------------------
;Entra: BX -> file handle
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
setChar	endp	

;
;--------------------------------------------------------------------
;Funcao Le um string do teclado e coloca no buffer apontado por BX
;		gets(char *s -> bx)
;--------------------------------------------------------------------
gets	proc	near
	push	bx

	mov		ah,0ah						; L・uma linha do teclado
	lea		dx,String
	mov		byte ptr String, MAXSTRING-4	; 2 caracteres no inicio e um eventual CR LF no final
	int		21h

	lea		si,String+2					; Copia do buffer de teclado para o FileName
	pop		di
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0			; Coloca marca de fim de string
	ret
gets	endp

;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------
