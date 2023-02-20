/*--------------------------------------------------------------Drops-----------------------------------------*/
drop table pessoas cascade constraints;
drop table alunos cascade constraints;
drop table funcionarios cascade constraints;
drop table instrutores cascade constraints;
drop table limpeza cascade constraints;
drop table categorias cascade constraints;
drop table veiculos cascade constraints;
drop table aulas cascade constraints;
drop table pratica cascade constraints;
drop table teorica cascade constraints;
drop table sala cascade constraints;
drop table oficina cascade constraints;
drop table aprende cascade constraints;
drop table vai cascade constraints;
drop table limpa cascade constraints;
/*----------------------------------------------------------------Tables------------------------------------*/
create table pessoas(
    cc_p number(8) not null,
    nome_p varchar2(50) not null,
    data_n_p Date not null,
    sexo varchar2(9)not null,
    telemovel_p number(9) not null,
    email_p varchar2(30) not null,
    morada_p varchar2(80)not null   
);

create table alunos(
 cc_p number(8) not null
);

create table funcionarios(
 cc_p number(8) not null,
 salario decimal(6,2) not null,
 data_entrada Date not null 
);

create table instrutores(
 cc_p number(8) not null
);

create table limpeza(
 cc_p number(8) not null
 );
 
 create table categorias(
 id_c varchar2(3) not null
 );
 
 create table veiculos(
 matricula varchar2(8) not null,
 marca varchar2(10) not null,
 modelo varchar(20) not null,
 ano number(4) not null,
 tipo varchar2(30),
id_c varchar2(3) not null,
nipc number(9) not null
 );
 
 create table aulas(
 cc_p number(8) not null,
 hora number(2) not null, 
 data_a Date not null
 );
 
create table pratica(
 cc_p number(8) not null,
 hora number(2) not null, 
  data_a Date not null,
  matricula varchar2(8) not null
);


create table teorica(
 cc_p number(8) not null,
  hora number(2) not null, 
  data_a Date not null,
  n_sala number(2) not null
);

create table sala(
n_sala number(2) not null,
capacidade_s number(2) not null);

create table oficina(
nipc number(9) not null,
nome_o varchar2(30) not null,
email_o varchar2(30) not null,
telefone_o number(9) not null,
morada_o varchar2(30)not null
);

create table aprende(
 cc_aluno number(8) not null,
 id_c varchar2(3) not null
);

create table vai(
cc_aluno number(8)not null,
cc_instrutor number(8) not null,
hora number(2) not null,
data_a Date not null
);

create table limpa(
cc_limpeza number(8) not null,
n_sala number(2) not null
);

/*--------------------------------------------------------------------chaves primarias--------------------------------------------------*/
alter table pessoas add constraint pk_pessoas primary key(cc_p);
alter table alunos add constraint pk_alunos primary key(cc_p);
alter table funcionarios add constraint pk_funcionarios primary key(cc_p);
alter table instrutores add constraint pk_instrutores primary key(cc_p);
alter table limpeza add constraint pk_limpeza primary key(cc_p);
alter table categorias add constraint pk_categorias primary key(id_c);
alter table veiculos add constraint pk_veiculos primary key(matricula);
alter table aulas add constraint pk_aulas primary key(cc_p,hora,data_a);
alter table pratica add constraint pk_pratica primary key(cc_p, hora, data_a);
alter table teorica add constraint pk_teorica primary key(cc_p, hora, data_a);
alter table sala add constraint pk_sala primary key(n_sala);
alter table oficina add constraint pk_oficina primary key(nipc);

alter table aprende add constraint pk_aprende primary key(cc_aluno,id_c);
alter table vai add constraint pk_vai primary key (cc_aluno,cc_instrutor,hora,data_a);
alter table limpa add constraint pk_limpa primary key(cc_limpeza,n_sala);

/*----------------------------------------------------------------------chaves estrangeiras------------------------------------*/
alter table alunos add constraint fk_alunos foreign key (cc_p) references pessoas(cc_p);
alter table funcionarios add constraint fk_funcionarios foreign key (cc_p) references pessoas(cc_p);
alter table instrutores add constraint fk_instrutores foreign key (cc_p) references funcionarios(cc_p);
alter table limpeza add constraint fk_limpeza foreign key (cc_p) references funcionarios(cc_p);
alter table veiculos add constraint fk_veiculos foreign key (id_c) references categorias(id_c);
alter table aulas add constraint fk_aulas foreign key (cc_p) references instrutores(cc_p);
alter table teorica add constraint fk_teoricasA foreign key (cc_p,hora,data_a) references aulas(cc_p,hora,data_a);
alter table teorica add constraint fk_teoricasS foreign key (n_sala) references sala(n_sala);
alter table pratica add constraint fk_praticasA foreign key (cc_p,hora,data_a) references aulas(cc_p,hora,data_a);
alter table pratica add constraint fk_praticasV foreign key (matricula) references veiculos(matricula);

alter table aprende add constraint fk_aprendeA foreign key (cc_aluno) references alunos(cc_p);
alter table aprende add constraint fk_aprendeC foreign key (id_c) references categorias(id_c);
alter table vai add constraint fk_vaiAluno foreign key (cc_aluno) references alunos(cc_p);
alter table vai add constraint fk_vaiAula foreign key (cc_instrutor,hora,data_a) references aulas(cc_p,hora,data_a);
alter table limpa add constraint fk_limpaL foreign key(cc_limpeza) references limpeza(cc_p);
alter table limpa add constraint fk_limpaS foreign key(n_sala) references sala(n_sala);


/*----------------------------------------------Restricoes--------------------------------------*/
alter table pessoas add constraint chk_email check (email_p like '%_@__%.__%');
alter table funcionarios add constraint minSalario check(salario >= 740.00);
alter table sala add constraint minCapacidade check(capacidade_s > =0);
alter table aulas add constraint horario check(hora>=9 and hora<=20);
/*-------------------------------------------------Views----------------------------------------------------*/
create or replace view pessoas_alunos AS
  SELECT * 
  FROM pessoas inner join alunos using(cc_p)
;

create or replace view pessoas_funcionarios AS
SELECT * 
FROM pessoas inner join funcionarios using (cc_p)
;
create or replace view pessoas_instrutores AS
  SELECT * 
  FROM pessoas_funcionarios inner join instrutores using(cc_p)
;

create or replace view pessoas_limpeza AS
SELECT *
FROM pessoas_funcionarios inner join limpeza using (cc_p)
; 

create or replace view aulas_praticas As
Select *
From aulas inner join pratica using(cc_p, hora, data_a)
;

create or replace view aulas_teoricas As
Select *
From aulas inner join teorica using(cc_p, hora, data_a)
;


/*--------------------------------------------------------------Triggers----------------------------------------------------*/
create or replace trigger control_idade
before insert on pessoas
for each row
begin
    if :new.data_n_p >  add_months(sysdate , -12*18)  then
       RAISE_APPLICATION_ERROR(-20001, 'NAO TEM IDADE SUFICIENTE');
    end if;
end;
    
/
create or replace trigger control_data_aulas
before insert on aulas
for each row
begin
    if sysdate  <  :new.data_a then
       RAISE_APPLICATION_ERROR(-20001, 'DATA INVALIDA');
    end if;
end;
    
/
create or replace trigger control_ano_veiculo
before insert on veiculos
for each row
begin
    if :new.ano >  TO_NUMBER(to_char(sysdate, 'YYYY'))  then
       RAISE_APPLICATION_ERROR(-20001, 'ANO INVALIDO');
    end if;
end;
    
/

/*----------------------------------------------------------------------------Triggers Alunos-----------------------------------------------------------*/
create or replace trigger insere_aluno
	instead of insert on pessoas_alunos
    for each row
	begin
        insert into pessoas values(:new.cc_p, :new.nome_p, :new.data_n_p, :new.sexo, :new.telemovel_p, :new.email_p, :new.morada_p);
        insert into alunos values(:new.cc_p);
  end;
/
create or replace trigger atualiza_aluno
	instead of update on pessoas_alunos
    for each row
	begin
        update pessoas set cc_p = :new.cc_p, nome_p=:new.nome_p,data_n_p= :new.data_n_p, sexo=:new.sexo,telemovel_p= :new.telemovel_p,email_p= :new.email_p,morada_p= :new.morada_p where cc_p = :new.cc_p;
        update alunos set cc_p = :new.cc_p where cc_p = :new.cc_p;
  end;
/
create or replace trigger apaga_aluno
	instead of delete on pessoas_alunos
    for each row
	begin
        delete from aprende where cc_aluno = :old.cc_p;
        delete from alunos where cc_p = :old.cc_p;
        delete from pessoas where cc_p = :old.cc_p;
  end;
/
/*----------------------------------------------------------------------------Triggers Limpeza-----------------------------------------------------------*/
create or replace trigger insere_limpeza
instead of insert on pessoas_limpeza
for each row 
begin 
 insert into pessoas values(:new.cc_p, :new.nome_p, :new.data_n_p, :new.sexo, :new.telemovel_p, :new.email_p, :new.morada_p);
        insert into funcionarios values(:new.cc_p,:new.salario,:new.data_entrada);
        insert into limpeza values(:new.cc_p);
    
     end;
     /
     create or replace trigger atualiza_limpeza
	instead of update on pessoas_limpeza
    for each row
	begin
        update pessoas set cc_p = :new.cc_p, nome_p=:new.nome_p,data_n_p= :new.data_n_p, sexo=:new.sexo,telemovel_p= :new.telemovel_p,email_p= :new.email_p,morada_p= :new.morada_p where cc_p = :new.cc_p;
        update funcionarios set cc_p = :new.cc_p, salario= :new.salario, data_entrada=:new.data_entrada where cc_p = :new.cc_p;
        update limpeza set cc_p=:new.cc_p where cc_p=:new.cc_p;
       
  end;
/
create or replace trigger apaga_limpeza
	instead of delete on pessoas_limpeza
    for each row
	begin
        delete from limpa where cc_limpeza = :old.cc_p;
        delete from limpeza where cc_p = :old.cc_p;
        delete from funcionarios where cc_p= : old.cc_p;
        delete from pessoas where cc_p=: old.cc_p;
  end;
/
/*----------------------------------------------------------------------------Triggers Instrutores-----------------------------------------------------------*/
create or replace trigger insere_instrutor
instead of insert on pessoas_instrutores
for each row 
begin 
 insert into pessoas values(:new.cc_p, :new.nome_p, :new.data_n_p, :new.sexo, :new.telemovel_p, :new.email_p, :new.morada_p);
        insert into funcionarios values(:new.cc_p,:new.salario,:new.data_entrada);
        insert into instrutores values(:new.cc_p);
     end;
     /
     create or replace trigger atualiza_instrutor
	instead of update on pessoas_instrutores
    for each row
	begin
        update pessoas set cc_p = :new.cc_p, nome_p=:new.nome_p,data_n_p= :new.data_n_p, sexo=:new.sexo,telemovel_p= :new.telemovel_p,email_p= :new.email_p,morada_p= :new.morada_p where cc_p = :new.cc_p;
        update funcionarios set cc_p = :new.cc_p, salario= :new.salario, data_entrada=:new.data_entrada where cc_p = :new.cc_p;
        update instrutores set cc_p=:new.cc_p where cc_p=:new.cc_p;
  end;
/
create or replace trigger apaga_instrutor
	instead of delete on pessoas_instrutores
    for each row
	begin
        delete from instrutores where cc_p=: old.cc_p;
        delete from funcionarios where cc_p= : old.cc_p;
        delete from pessoas where cc_p=: old.cc_p;
  end;
/

create or replace trigger insere_teoricas
instead of insert on aulas_teoricas
for each row 
begin 
insert into aulas values(:new.cc_p, :new.hora, :new.data_a);
 insert into teorica values(:new.cc_p, :new.hora, :new.data_a, :new.n_sala);
   
     end;
     /
       
     create or replace trigger insere_praticas
instead of insert on aulas_praticas
for each row 
begin 
insert into aulas values(:new.cc_p, :new.hora, :new.data_a);
 insert into pratica values(:new.cc_p, :new.hora, :new.data_a, :new.matricula);
  
    
     end;
     /

/*---------------------------------------------------------------------------------------------------------Inserts----------------------------------------------*/
insert into pessoas_instrutores values(10000001, 'Artur Miguel Dias',TO_DATE('1971-05-01','yyyy-mm-dd'),'Masculino', 212948300,'amd@fct.unl.com','Rua da Recursividade',2200.00,TO_DATE('1999-09-09','yyyy-mm-dd'));
insert into pessoas_instrutores values(03450002, 'Antonio Alarcao Ravara',TO_DATE('1979-06-01','yyyy-mm-dd'),'Masculino', 432101234,'aravara@fct.unl.com','Rua Palindromo Caires',1940.00,TO_DATE('2002-02-02','yyyy-mm-dd'));
insert into pessoas_instrutores values(00486403, 'Armanda Rodrigues Grueau',TO_DATE('1982-02-14','yyyy-mm-dd'),'Feminino', 962962962,'a.rodrigues@fct.unl.com','Rua Temporal',1900.00,TO_DATE('2002-03-03','yyyy-mm-dd'));
insert into pessoas_instrutores values(00045604, 'Jorge Mathias Knorr',TO_DATE('1984-10-05','yyyy-mm-dd'),'Masculino', 742742742,'mkn@fct.unl.com','Rua da Consulta',1500.00,TO_DATE('2009-09-09','yyyy-mm-dd'));
insert into pessoas_instrutores values(03456005, 'Jorge Manuel Andre',TO_DATE('1981-11-01','yyyy-mm-dd'),'Masculino', 642642642,'jmla@fct.unl.com','Rua do Naufragio',1700.00,TO_DATE('2005-05-05','yyyy-mm-dd'));
insert into pessoas_instrutores values(02345006, 'Claudio Fernandes',TO_DATE('1982-01-06','yyyy-mm-dd'),'Masculino', 323323323,'caf@fct.unl.com','Rua da Esperanca',2000.00,TO_DATE('2000-08-28','yyyy-mm-dd'));
insert into pessoas_instrutores values(08363007, 'Antonio Malheiro',TO_DATE('1978-01-01','yyyy-mm-dd'),'Masculino', 252252252,'ajm@fct.unl.com','Rua do Recurso',1400.00,TO_DATE('2001-01-01','yyyy-mm-dd'));
insert into pessoas_instrutores values(00231008, 'Carla Goncalves Ferreira',TO_DATE('1985-12-01','yyyy-mm-dd'),'Feminino', 973973973,'carla.ferreira@fct.unl.com','Rua Abstrata',1600.00,TO_DATE('2007-07-07','yyyy-mm-dd'));
insert into pessoas_instrutores values(00023349, 'Maria Fatima Miguens',TO_DATE('1965-07-15','yyyy-mm-dd'),'Feminino', 482482482,'mfvm@fct.unl.com','Rua da Pitura ',1950.00,TO_DATE('1998-05-05','yyyy-mm-dd'));
insert into pessoas_instrutores values(10345010, 'Herberto Jesus Silva',TO_DATE('1966-06-16','yyyy-mm-dd'),'Masculino', 752752752,'hdjs@fct.unl.com','Rua Matricial',1850.00,TO_DATE('1999-04-04','yyyy-mm-dd'));

insert into pessoas_limpeza values(10089880, 'Rosa Santos Mota',TO_DATE('1984-04-04','yyyy-mm-dd'),'Feminino', 457457457,'ouro@gmail.com','Rua de Dom Manuel II',900.00,TO_DATE('2000-09-16','yyyy-mm-dd'));
insert into pessoas_limpeza values(20450000, 'Luis Vaz de Camoes',TO_DATE('1985-05-04','yyyy-mm-dd'),'Masculino', 147147147,'lusiadas@hotmail.com','Rua Fernando Pessoa',870.00,TO_DATE('2020-02-14','yyyy-mm-dd'));
insert into pessoas_limpeza values(30102300, 'Cristiano Ronaldo',TO_DATE('1985-02-05','yyyy-mm-dd'),'Masculino', 258258258,'cr7@gmail.com','Rua da Carreira',800.00,TO_DATE('2010-11-21','yyyy-mm-dd'));
insert into pessoas_limpeza values(40005400, 'Cristina Maria Jorge Ferreira',TO_DATE('1977-09-09','yyyy-mm-dd'),'Feminino', 369369369,'tvi@yahoo.com','Travessa da Peixaria',740.00,TO_DATE('2002-02-22','yyyy-mm-dd'));

/*------------------------------------------------------------------------Alunos-------------------------------------------------------------------------------*/
insert into pessoas_alunos values(15999999,'Agathinus Tryhard',TO_DATE('2001-06-03','yyyy-mm-dd'),'Masculino',939393939,'aty@gmail.com','Rua da India');
insert into pessoas_alunos values(13345678,'Ze da Tasca',TO_DATE('2000-02-03','yyyy-mm-dd'),'Masculino',920000000,'zdt@gmail.com','Rua da Tasca');
insert into pessoas_alunos values(13565678,'Marcelo Rebelo de Sousa',TO_DATE('1948-12-12','yyyy-mm-dd'),'Masculino',943333333,'MRS@gmail.com','Rua do Presidente');
insert into pessoas_alunos values(13345698,'Claudia Maria',TO_DATE('1922-06-03','yyyy-mm-dd'),'Feminino',909090909,'cm@gmail.com','Rua da Amadora');
insert into pessoas_alunos values(13345688,'Maria Borges',TO_DATE('2001-06-03','yyyy-mm-dd'),'Masculino',923456789,'mb@gmail.com','Rua da Tola');
insert into pessoas_alunos values(14345678,'Agata Torres',TO_DATE('1945-01-23','yyyy-mm-dd'),'Feminino',973456789,'at@gmail.com','Rua da Amadora');
insert into pessoas_alunos values(13340678,'Ze Artolo',TO_DATE('2001-08-13','yyyy-mm-dd'),'Masculino',973450789,'za@gmail.com','Rua do Artolas');
insert into pessoas_alunos values(13366679,'Yuri Iruy',TO_DATE('1999-06-12','yyyy-mm-dd'),'Masculino',923445489,'yi@gmail.com','Rua do Artolas');
insert into pessoas_alunos values(13345600,'Joe Mama',TO_DATE('1970-05-01','yyyy-mm-dd'),'Masculino',912256789,'jm@gmail.com','Rua do Troll');
insert into pessoas_alunos values(33345678,'Ana Cacho',TO_DATE('1960-04-03','yyyy-mm-dd'),'Feminino',979999999,'ac@gmail.com','Rua da Amadora');
insert into pessoas_alunos values(43345678,'Joao Albany',TO_DATE('1950-05-03','yyyy-mm-dd'),'Masculino',95995999,'ja@gmail.com','Rua do Paquistao');
insert into pessoas_alunos values(44345678,'Hugo Boss',TO_DATE('1997-10-13','yyyy-mm-dd'),'Masculino',923487124,'hb@gmail.com','Rua do Colombo');
insert into pessoas_alunos values(13985678,'Yuri Tarded',TO_DATE('1999-10-24','yyyy-mm-dd'),'Masculino',934345740,'yr@gmail.com','Rua do Troll');
insert into pessoas_alunos values(13349978,'Timbe da Silva',TO_DATE('1968-03-15','yyyy-mm-dd'),'Masculino',908888888,'tds@gmail.com','Rua do Comboio');
insert into pessoas_alunos values(13345908,'Artur Morgan',TO_DATE('2000-11-05','yyyy-mm-dd'),'Masculino',934761390,'am@gmail.com','Rua de Blackwater');
insert into pessoas_alunos values(93345678,'Amelia Clementina',TO_DATE('1995-12-25','yyyy-mm-dd'),'Feminino',903645332,'ac@gmail.com','Rua da Fonte');
insert into pessoas_alunos values(99345678,'Joana Relote',TO_DATE('1995-10-25','yyyy-mm-dd'),'Feminino',903685332,'jr@gmail.com','Rua da Cozinha');
insert into pessoas_alunos values(35000000,'Clementina Ramboia',TO_DATE('1985-07-25','yyyy-mm-dd'),'Feminino',903600032,'cr@gmail.com','Rua da Fonte');
insert into pessoas_alunos values(55545678,'Maria Dois Dentes',TO_DATE('2000-02-15','yyyy-mm-dd'),'Feminino',913645332,'mdd@gmail.com','Rua Fixe');
insert into pessoas_alunos values(24345678,'Aga Ramos',TO_DATE('1950-11-11','yyyy-mm-dd'),'Feminino',903640332,'ar@gmail.com','Rua do Drip');
insert into pessoas_alunos values(93345568,'Leandro Borges',TO_DATE('2002-08-07','yyyy-mm-dd'),'Masculino',970000120,'lb@gmail.com','Rua do Carro');
insert into pessoas_alunos values(15956999,'Enzo Ferrari',TO_DATE('2002-07-03','yyyy-mm-dd'),'Masculino',939390939,'ef@gmail.com','Rua do F1');
insert into pessoas_alunos values(15994769,'Mc Bolicau',TO_DATE('2001-06-09','yyyy-mm-dd'),'Masculino',929393939,'mb@gmail.com','Rua do Porto Brandao');
insert into pessoas_alunos values(15987999,'Urtiga Pica',TO_DATE('1990-08-09','yyyy-mm-dd'),'Masculino',900000000,'up@gmail.com','Rua do Mato');
insert into pessoas_alunos values(15934569,'Sem Nome',TO_DATE('1986-06-17','yyyy-mm-dd'),'Masculino',938754854,'sn@gmail.com','Rua do Anonimato');
insert into pessoas_alunos values(15932199,'Henry Ford',TO_DATE('1976-04-10','yyyy-mm-dd'),'Masculino',939836374,'hf@gmail.com','Rua do Carro');
insert into pessoas_alunos values(15865499,'Maria Droguitas',TO_DATE('2001-06-03','yyyy-mm-dd'),'Feminino',909387939,'md@gmail.com','Rua do Porto Brandao');
insert into pessoas_alunos values(17899999,'Tome Boiola',TO_DATE('2001-01-17','yyyy-mm-dd'),'Masculino',913579543,'tb@gmail.com','Rua do Presidente');
insert into pessoas_alunos values(16454999,'Uga Buga',TO_DATE('2001-06-03','yyyy-mm-dd'),'Masculino',977777939,'ub@gmail.com','Rua da Caverna');
insert into pessoas_alunos values(18345678,'Marta Marmeleira',TO_DATE('1944-01-23','yyyy-mm-dd'),'Feminino',903456789,'mm@gmail.com','Rua da Rola');
insert into pessoas_alunos values(13709780,'Cristiano Ronaldo',TO_DATE('1985-02-05','yyyy-mm-dd'),'Masculino',945313212,'cr7@gmail.com','Rua do Rico');
insert into pessoas_alunos values(93546679,'Elon Musk da Wish',TO_DATE('1999-02-28','yyyy-mm-dd'),'Masculino',922636389,'emdw@gmail.com','Rua do Rico');
insert into pessoas_alunos values(90345608,'Pedro Pessegueiro',TO_DATE('1980-02-28','yyyy-mm-dd'),'Masculino', 123459989,'pco@gmail.com','Rua do Paquistao');
insert into pessoas_alunos values(91345600,'Joao Biqueira',TO_DATE('1989-05-01','yyyy-mm-dd'),'Masculino',913356789,'jb@gmail.com','Rua do Congo');
insert into pessoas_alunos values(97345678,'Timon Pumba',TO_DATE('1965-02-03','yyyy-mm-dd'),'Masculino',997899999,'tp@gmail.com','Rua de Timor');
insert into pessoas_alunos values(50345678,'Joao Camacho',TO_DATE('1998-02-13','yyyy-mm-dd'),'Masculino',973406789,'jc@gmail.com','Rua da Amadora');
insert into pessoas_alunos values(53345678,'Dj Khaled',TO_DATE('1978-05-03','yyyy-mm-dd'),'Masculino',97995999,'dk@gmail.com','Rua do Musica');
insert into pessoas_alunos values(87345678,'Vitorino Guitarrista',TO_DATE('1996-02-18','yyyy-mm-dd'),'Masculino',973487124,'vg@gmail.com','Rua do Colombo');
insert into pessoas_alunos values(67985678,'Otavio Paco',TO_DATE('1949-10-24','yyyy-mm-dd'),'Masculino',934654740,'op@gmail.com','Rua do Rio');
insert into pessoas_alunos values(09349978,'Orlando da Silva',TO_DATE('1978-03-15','yyyy-mm-dd'),'Masculino',978889088,'ods@gmail.com','Rua da Rola');
insert into pessoas_alunos values(08345908,'Armando Topete',TO_DATE('1976-12-05','yyyy-mm-dd'),'Masculino',935671390,'at@gmail.com','Rua da Oila');
insert into pessoas_alunos values(07345678,'Tatiana Barreiro',TO_DATE('1985-07-15','yyyy-mm-dd'),'Feminino',903648932,'tb@gmail.com','Rua da Quelha');
insert into pessoas_alunos values(06345678,'Urze Relote',TO_DATE('2000-09-22','yyyy-mm-dd'),'Feminino',903456732,'ur@gmail.com','Rua da Amadora');
insert into pessoas_alunos values(96020000,'Anita Lourenco',TO_DATE('2001-02-26','yyyy-mm-dd'),'Feminino',91230032,'al@gmail.com','Rua do Tremoco');
insert into pessoas_alunos values(01555678,'Irene Batata',TO_DATE('1990-04-30','yyyy-mm-dd'),'Feminino',973645322,'ib@gmail.com','Rua do Caverna');
insert into pessoas_alunos values(00545678,'Marina Alves',TO_DATE('1987-07-15','yyyy-mm-dd'),'Feminino',913647882,'ma@gmail.com','Rua Fixe');
insert into pessoas_alunos values(04340978,'Marlene Chaves',TO_DATE('1967-09-15','yyyy-mm-dd'),'Feminino',903092332,'mc@gmail.com','Rua Beep Beep');
insert into pessoas_alunos values(45340008,'Paula Oterga',TO_DATE('1996-07-05','yyyy-mm-dd'),'Feminino',900612332,'po@gmail.com','Rua de Espanha');
insert into pessoas_alunos values(73398678,'Jacinto Tolga',TO_DATE('2000-05-14','yyyy-mm-dd'),'Masculino',973648332,'jt@gmail.com','Rua do Troquete');
insert into pessoas_alunos values(20789678,'Lucas Lopes',TO_DATE('1998-03-09','yyyy-mm-dd'),'Masculino',903745632,'ll7@gmail.com','Rua da Fonte');
insert into pessoas_alunos values(22127678,'Hilda Pereira',TO_DATE('1975-01-01','yyyy-mm-dd'),'Feminino',903640132,'hp6@gmail.com','Rua da Fonte');
insert into pessoas_alunos values(24321218,'Diana Rodrigues',TO_DATE('1959-11-11','yyyy-mm-dd'),'Feminino',903678932,'dr@gmail.com','Rua do Porto');
insert into pessoas_alunos values(25345999,'Hortencia Guapa',TO_DATE('1954-02-25','yyyy-mm-dd'),'Feminino', 903678832,'hg@gmail.com','Rua da Fruta');
insert into pessoas_alunos values(26376578,'Julia Guerreira',TO_DATE('2004-01-02','yyyy-mm-dd'),'Feminino', 904567332,'jg@gmail.com','Rua do Bocal');
insert into pessoas_alunos values(29123478,'Laura Broa',TO_DATE('2003-10-05','yyyy-mm-dd'),'Feminino', 903123331,'lb@gmail.com','Rua da Doca');
insert into pessoas_alunos values(30123678,'Toze Oila',TO_DATE('2003-06-03','yyyy-mm-dd'),'Masculino',919100098,'to@gmail.com','Rua do Carro');
insert into pessoas_alunos values(34399099,'Ultron Stark',TO_DATE('1999-06-03','yyyy-mm-dd'),'Masculino',919393939,'us@gmail.com','Rua do Timor');
insert into pessoas_alunos values(15979987,'Nuno Oliveira',TO_DATE('2004-01-22','yyyy-mm-dd'),'Masculino',930009879,'no@gmail.com','Rua do Altar');
insert into pessoas_alunos values(15957659,'Tomas  Henry',TO_DATE('2004-01-03','yyyy-mm-dd'),'Masculino',93233939,'ath@gmail.com','Rua do Altar');
insert into pessoas_alunos values(15983749,'Ana Costa',TO_DATE('2003-07-10','yyyy-mm-dd'),'Feminino',939392569,'ac@gmail.com','Rua do Timor');
insert into pessoas_alunos values(15996999,'Arlete Ferreira',TO_DATE('2000-09-03','yyyy-mm-dd'),'Feminino',939334589,'af@gmail.com','Rua do Troquete');

/* ----------------------------------------Categorias--------------------------------- */
insert into categorias values ('A');
insert into categorias values ('A2');
insert into categorias values ('B');
insert into categorias values ('BE');
insert into categorias values ('C');
insert into categorias values ('C1');
insert into categorias values ('C1E');
insert into categorias values ('D');
insert into categorias values ('DE');
insert into categorias values ('D1');
insert into categorias values ('D1E');

/* -----------------------------Oficinas-------------------------------------- */
insert into oficina values (123456789, 'Oficina Ze do Pipo', 'srzedopipo@gmail.com', 914739476, 'Rua dos carros');
insert into oficina values (987654321, 'Oficina Tira Pecas', 'tirapecas@gmail.com', 914732635, 'Rua dos carros');
insert into oficina values (114253647, 'Oficina Alta Honda', 'altahonda@gmail.com', 914397385, 'Rua dos carros');
insert into oficina values (495826374, 'Oficina do Roubo e Mecanica', 'roubomecanica@gmail.com', 916001965, 'Rua dos carros');
insert into oficina values (492376109, 'Oficina Capsule Corp ', 'capsulecorp@gmail.com', 914501276, 'Rua dos carros');
insert into oficina values (975239456, 'Oficina Tres Pancadas', 'trespancadas@gmail.com', 913187889, 'Rua dos carros');
insert into oficina values (145917356, 'Oficina Bigode Tuga', 'bigodetuga@gmail.com', 998576394, 'Rua dos carros');
insert into oficina values (590274578, 'Oficina 5 Rodas', '5rodas@gmail.com', 912900876, 'Rua dos carros');

/* -----------------------------Veiculos-------------------------------------- */
insert into veiculos values ('56-HV-85', 'Mini', 'Cooper', 2015, 'Ligeiro', 'B', 123456789);
insert into veiculos values ('32-UR-56', 'Honda', 'NC750X', 2018, 'Motociclo', 'A2', 123456789);
insert into veiculos values ('33-TV-34', 'KTM', 'Adventure 390', 2015, 'Motociclo', 'A2', 123456789);
insert into veiculos values ('89-AE-65', 'Renault', 'Kangoo', 2002, 'Pesado Mercadorias', 'C1E', 123456789);
insert into veiculos values ('17-RE-63', 'Bentley', 'Bentayga', 2008, 'Ligeiro', 'B', 987654321);
insert into veiculos values ('34-JN-55', 'BMW', 'I8', 1997, 'Ligeiro', 'B', 987654321);
insert into veiculos values ('45-GH-63', 'Ferrari', '812', 2013, 'Ligeiro', 'B', 987654321);
insert into veiculos values ('90-WF-45', 'Opel', 'Corsa', 2011, 'Ligeiro', 'BE', 123456789);
insert into veiculos values ('42-JK-92', 'Renault', 'Traffic', 2008, 'Pesado Mercadorias', 'C1E', 123456789);
insert into veiculos values ('34-FD-43', 'BMW', 'G310R', 2005, 'Motociclo', 'A2', 123456789);
insert into veiculos values ('67-OI-35', 'Citroen', 'Arona', 1997, 'Pesado Passageiros', 'D', 114253647);
insert into veiculos values ('89-AO-94', 'Suzuki', 'GSX 250 R', 1997, 'Motociclo', 'A2', 114253647);
insert into veiculos values ('66-QW-63', 'Renaut', 'Carro', 1997, 'Pesado Passageiros', 'D1E', 114253647);
insert into veiculos values ('32-TF-24', 'TAP', 'Triciclo', 2011, 'Pesado Passageiros', 'D1', 495826374);
insert into veiculos values ('33-GH-95', 'Yamaha', 'MT-03', 2003, 'Motociclo', 'A2', 495826374);
insert into veiculos values ('44-AS-45', 'EasyJet', 'Kabum', 2017, 'Pesado Mercadorias', 'C1', 495826374);
insert into veiculos values ('67-ER-34', 'Cupra', 'Ateca', 2016, 'Ligeiro', 'B', 975239456);
insert into veiculos values ('00-YH-46', 'Audi', 'A1', 2001, 'Ligeiro', 'B', 975239456);
insert into veiculos values ('43-JK-63', 'Ford', 'Focus', 2017, 'Ligeiro', 'BE', 975239456);
insert into veiculos values ('12-UI-52', 'Iphone', 'X', 2019, 'Pesado Passageiros', 'DE', 975239456);
insert into veiculos values ('97-QL-78', 'McRoyal', 'Bacon', 2011, 'Pesado Mercadorias', 'C1E', 145917356);
insert into veiculos values ('21-KJ-76', 'Citroen', 'C1', 2008, 'Motociclo', 'A', 145917356);
insert into veiculos values ('23-AP-65', 'Carro', 'Qanda', 1997, 'Pesado Passageiros', 'DE', 145917356);
insert into veiculos values ('34-HG-45', 'Ford', 'Fiesta', 2011, 'Ligeiro', 'BE', 590274578);
insert into veiculos values ('68-WC-65', 'Samsung', 'Galaxy', 2004, 'Pesado Passageiros', 'DE', 590274578);
insert into veiculos values ('56-WC-75', 'MAN', 'WOMAN', 2004, 'Pesado Passageiros', 'D', 590274578);
insert into veiculos values ('96-KW-90', 'Lenovo', 'Thinkpad', 2011, 'Pesado Mercadorias', 'C1', 590274578);
insert into veiculos values ('57-IM-76', 'JBL', 'Flip Essential', 2004, 'Pesado Passageiros', 'D1E', 492376109);
insert into veiculos values ('78-YB-43', 'Reanul', 'Traffic', 1997, 'Pesado Passageiros', 'D1', 492376109);
insert into veiculos values ('16-UN-34', 'Jeep', 'Renegade', 2011, 'Ligeiro', 'B', 492376109);

/* -----------------------------Salas-------------------------------------- */
insert into sala values(1, 30);
insert into sala values(2, 30);
insert into sala values(3, 30);
insert into sala values(4, 30);
insert into sala values(5, 30);
insert into sala values(6, 30);
insert into sala values(7, 50);
insert into sala values(8, 50);


/* -----------------------------Aulas------------------------------------ */
insert into aulas_teoricas values(10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(10000001, 20, TO_DATE('2022-01-15','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'), 6);
insert into aulas_teoricas values(10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(10000001, 20, TO_DATE('2022-02-15','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(10000001, 20, TO_DATE('2022-05-15','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'), 5);
insert into aulas_teoricas values(03450002, 17, TO_DATE('2022-02-01','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(03450002, 19, TO_DATE('2022-02-15','yyyy-mm-dd'), 1);
insert into aulas_teoricas values(03450002, 18, TO_DATE('2022-03-30','yyyy-mm-dd'), 6);
insert into aulas_teoricas values(00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'), 2);
insert into aulas_teoricas values(00486403, 17, TO_DATE('2022-02-01','yyyy-mm-dd'), 2);
insert into aulas_teoricas values(00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'), 8);
insert into aulas_teoricas values(00045604, 19, TO_DATE('2022-04-30','yyyy-mm-dd'), 6);
insert into aulas_teoricas values(00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'), 2);
insert into aulas_teoricas values(00045604, 19, TO_DATE('2022-05-30','yyyy-mm-dd'), 8);
insert into aulas_teoricas values(03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'), 3);
insert into aulas_teoricas values(02345006, 17, TO_DATE('2022-01-05','yyyy-mm-dd'), 3);
insert into aulas_teoricas values(02345006, 19, TO_DATE('2022-01-10','yyyy-mm-dd'), 3);
insert into aulas_teoricas values(02345006, 18, TO_DATE('2022-05-25','yyyy-mm-dd'), 3);



insert into aulas_praticas values(02345006, 9, TO_DATE('2022-01-05','yyyy-mm-dd'),'56-HV-85');
insert into aulas_praticas values(02345006, 10, TO_DATE('2022-01-10','yyyy-mm-dd'),'32-UR-56');
insert into aulas_praticas values(02345006, 11, TO_DATE('2022-01-25','yyyy-mm-dd'),'56-HV-85');
insert into aulas_praticas values(02345006, 12, TO_DATE('2022-02-05','yyyy-mm-dd'),'32-UR-56');
insert into aulas_praticas values(02345006, 13, TO_DATE('2022-02-10','yyyy-mm-dd'),'56-HV-85');
insert into aulas_praticas values(08363007, 16, TO_DATE('2022-01-05','yyyy-mm-dd'),'21-KJ-76');
insert into aulas_praticas values(08363007, 18, TO_DATE('2022-04-10','yyyy-mm-dd'),'33-GH-95');
insert into aulas_praticas values(08363007, 19, TO_DATE('2022-04-25','yyyy-mm-dd'),'90-WF-45');
insert into aulas_praticas values(08363007, 17, TO_DATE('2022-05-05','yyyy-mm-dd'),'57-IM-76');
insert into aulas_praticas values(00231008, 20, TO_DATE('2022-01-05','yyyy-mm-dd'),'32-UR-56');
insert into aulas_praticas values(00231008, 18, TO_DATE('2022-01-10','yyyy-mm-dd'),'32-UR-56');
insert into aulas_praticas values(00231008, 16, TO_DATE('2022-01-25','yyyy-mm-dd'),'32-UR-56');
insert into aulas_praticas values(00231008, 17, TO_DATE('2022-02-05','yyyy-mm-dd'),'21-KJ-76');
insert into aulas_praticas values(00231008, 11, TO_DATE('2022-04-05','yyyy-mm-dd'),'21-KJ-76');
insert into aulas_praticas values(00231008, 13, TO_DATE('2022-05-25','yyyy-mm-dd'),'44-AS-45');
insert into aulas_praticas values(00023349, 20, TO_DATE('2022-01-05','yyyy-mm-dd'),'90-WF-45');
insert into aulas_praticas values(00023349, 19, TO_DATE('2022-01-10','yyyy-mm-dd'),'67-OI-35');
insert into aulas_praticas values(10345010, 10, TO_DATE('2022-01-10','yyyy-mm-dd'),'44-AS-45');

/*------------------------------------------------------Aprende-------------------------------------------------*/
insert into aprende values(15999999,'A');
insert into aprende values(15999999,'A2');
insert into aprende values(15999999,'B');
insert into aprende values(15999999,'BE');
insert into aprende values(15999999,'C');
insert into aprende values(15999999,'C1');
insert into aprende values(15999999,'C1E');
insert into aprende values(15999999,'D');
insert into aprende values(15999999,'DE');
insert into aprende values(15999999,'D1');
insert into aprende values(15999999,'D1E');
insert into aprende values(13345678,'A');
insert into aprende values(13345678,'A2');
insert into aprende values(13565678,'B');
insert into aprende values(13345698,'BE');
insert into aprende values(13345698,'C');
insert into aprende values(13345688,'C1');
insert into aprende values(13565678,'C1E');
insert into aprende values(13345688,'D');
insert into aprende values(14345678,'DE');
insert into aprende values(13340678,'D1');
insert into aprende values(13366679,'D1E');
insert into aprende values(13366679,'A');
insert into aprende values(13366679,'A2');
insert into aprende values(13345600,'B');
insert into aprende values(13345600,'C');
insert into aprende values(33345678,'D1');
insert into aprende values(13345600,'D1E');
insert into aprende values(33345678,'A');
insert into aprende values(43345678,'A2');
insert into aprende values(33345678,'B');
insert into aprende values(43345678,'BE');
insert into aprende values(33345678,'C');
insert into aprende values(43345678,'C1');
insert into aprende values(43345678,'C1E');
insert into aprende values(43345678,'D');
insert into aprende values(43345678,'DE');
insert into aprende values(43345678,'D1');
insert into aprende values(43345678,'D1E');
insert into aprende values(44345678,'A');
insert into aprende values(44345678,'A2');
insert into aprende values(13985678,'C1');
insert into aprende values(13985678,'C1E');
insert into aprende values(13985678,'D');
insert into aprende values(13345908,'DE');
insert into aprende values(13345908,'D1');
insert into aprende values(13349978,'D1E');
insert into aprende values(93345678,'A');
insert into aprende values(93345678,'A2');
insert into aprende values(93345678,'B');
insert into aprende values(93345678,'BE');
insert into aprende values(93345678,'C');
insert into aprende values(93345678,'C1');
insert into aprende values(93345678,'C1E');
insert into aprende values(93345678,'D');
insert into aprende values(93345678,'DE');
insert into aprende values(93345678,'D1');
insert into aprende values(93345678,'D1E');
insert into aprende values(99345678,'A');
insert into aprende values(35000000,'A2');
insert into aprende values(35000000,'B');
insert into aprende values(55545678,'C1');
insert into aprende values(24345678,'A');
insert into aprende values(24345678,'A2');
insert into aprende values(93345568,'D');
insert into aprende values(15956999,'DE');
insert into aprende values(15956999,'D1');
insert into aprende values(15994769,'D1E');
insert into aprende values(15987999,'A');
insert into aprende values(15934569,'A2');
insert into aprende values(15932199,'B');
insert into aprende values(15865499,'C1');
insert into aprende values(17899999,'DE');
insert into aprende values(16454999,'D1');
insert into aprende values(18345678,'C');
insert into aprende values(13709780,'C1');
insert into aprende values(93546679,'C1E');
insert into aprende values(90345608,'D');
insert into aprende values(91345600,'DE');
insert into aprende values(97345678,'D1');
insert into aprende values(50345678,'D1E');
insert into aprende values(90345608,'A');
insert into aprende values(53345678,'A2');
insert into aprende values(87345678,'B');
insert into aprende values(67985678,'B');
insert into aprende values(09349978,'A');
insert into aprende values(08345908,'A');
insert into aprende values(07345678,'B');
insert into aprende values(06345678,'B');
insert into aprende values(96020000,'A');
insert into aprende values(01555678,'A');
insert into aprende values(00545678,'B');
insert into aprende values(04340978,'B');
insert into aprende values(45340008,'B');
insert into aprende values(73398678,'B');
insert into aprende values(20789678,'C');
insert into aprende values(22127678,'C1');
insert into aprende values(24321218,'C1E');
insert into aprende values(25345999,'A');
insert into aprende values(26376578,'A2');
insert into aprende values(29123478,'A2');
insert into aprende values(30123678,'B');
insert into aprende values(34399099,'A');
insert into aprende values(15996999,'B');
insert into aprende values(15983749,'B');
insert into aprende values(15957659,'B');
insert into aprende values(15979987,'B');

/*------------------------------------------------------------------------limpa-------------------------------------------*/
insert into limpa values(10089880,1);
insert into limpa values(10089880,2);
insert into limpa values(20450000,3);
insert into limpa values(20450000,4);
insert into limpa values(30102300,5);
insert into limpa values(30102300,6);
insert into limpa values(40005400,7);
insert into limpa values(40005400,8);



/*-----------------------------------------------------------vai-----------------------------------------------------*/

insert into vai values(15999999,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13345678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13565678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13345698,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13345688,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(14345678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13340678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13366679,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13345600,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(33345678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(43345678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(44345678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13985678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13349978,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13345908,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(93345678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(99345678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(35000000,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(55545678,10000001, 18, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(93345568,10000001, 20, TO_DATE('2022-01-15','yyyy-mm-dd'));
insert into vai values(15956999,10000001, 20, TO_DATE('2022-01-15','yyyy-mm-dd'));
insert into vai values(15994769,10000001, 20, TO_DATE('2022-01-15','yyyy-mm-dd'));
insert into vai values(15987999,10000001, 20, TO_DATE('2022-01-15','yyyy-mm-dd'));
insert into vai values(15934569,10000001, 20, TO_DATE('2022-01-15','yyyy-mm-dd'));
insert into vai values(15934569,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(15932199,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(15865499,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(17899999,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(16454999,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(93546679,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(90345608,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(91345600,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(97345678,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(50345678,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(08345908,10000001, 19, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(08345908,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(07345678,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(06345678,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(96020000,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(01555678,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(00545678,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(04340978,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(45340008,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(73398678,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(20789678,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(22127678,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(24321218,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(25345999,10000001, 18, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(24321218,10000001, 20, TO_DATE('2022-02-15','yyyy-mm-dd'));
insert into vai values(26376578,10000001, 20, TO_DATE('2022-02-15','yyyy-mm-dd'));
insert into vai values(29123478,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(30123678,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(15983749,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(15996999,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(18345678,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(13709780,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(93546679,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(90345608,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(91345600,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(97345678,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(50345678,10000001, 18, TO_DATE('2022-03-01','yyyy-mm-dd'));
insert into vai values(50345678,10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'));
insert into vai values(13345678,10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'));
insert into vai values(15999999,10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'));
insert into vai values(14345678,10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'));
insert into vai values(13345600,10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'));
insert into vai values(13985678,10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'));
insert into vai values(44345678,10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'));
insert into vai values(13349978,10000001, 20, TO_DATE('2022-03-15','yyyy-mm-dd'));
insert into vai values(15932199,10000001, 20, TO_DATE('2022-05-15','yyyy-mm-dd'));
insert into vai values(15999999,10000001, 20, TO_DATE('2022-05-15','yyyy-mm-dd'));
insert into vai values(25345999,10000001, 20, TO_DATE('2022-05-15','yyyy-mm-dd'));
insert into vai values(34399099,10000001, 20, TO_DATE('2022-05-15','yyyy-mm-dd'));
insert into vai values(22127678,10000001, 20, TO_DATE('2022-05-15','yyyy-mm-dd'));
insert into vai values(15999999,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(13345698,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(13345600,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(33345678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(43345678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(44345678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(13349978,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(13345908,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(93345678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(99345678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(35000000,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(15932199,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(18345678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(13709780,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(93546679,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(90345608,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(91345600,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(97345678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(50345678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(67985678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(30123678,03450002, 18, TO_DATE('2022-01-30','yyyy-mm-dd'));
insert into vai values(15999999,03450002, 17, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(43345678,03450002, 17, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(24321218,03450002, 17, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(15983749,03450002, 17, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(15999999,03450002, 19, TO_DATE('2022-02-15','yyyy-mm-dd'));
insert into vai values(96020000,03450002, 19, TO_DATE('2022-02-15','yyyy-mm-dd'));
insert into vai values(01555678,03450002, 19, TO_DATE('2022-02-15','yyyy-mm-dd'));
insert into vai values(15999999,03450002, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(01555678,03450002, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(20789678,03450002, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(26376578,03450002, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(15999999,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13345908,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(26376578,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(99345678,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(13345600,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(15987999,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(22127678,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(15994769,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(29123478,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(15983749,00486403, 17, TO_DATE('2022-01-01','yyyy-mm-dd'));
insert into vai values(50345678,00486403, 17, TO_DATE('2022-02-01','yyyy-mm-dd'));
insert into vai values(15999999,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(91345600,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(97345678,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(07345678,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(96020000,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(13366679,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(13345600,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(43345678,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(44345678,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(13985678,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(13349978,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(13345908,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(93345678,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(35000000,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(55545678,00486403, 18, TO_DATE('2022-03-30','yyyy-mm-dd'));
insert into vai values(15999999,00045604, 19, TO_DATE('2022-04-30','yyyy-mm-dd'));
insert into vai values(24345678,00045604, 19, TO_DATE('2022-04-30','yyyy-mm-dd'));
insert into vai values(15999999,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(13349978,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(15996999,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(15983749,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(15957659,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(08345908,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(07345678,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(06345678,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(96020000,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(01555678,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(00545678,00045604, 18, TO_DATE('2022-05-01','yyyy-mm-dd'));
insert into vai values(15999999,00045604, 19, TO_DATE('2022-05-30','yyyy-mm-dd'));
insert into vai values(96020000,00045604, 19, TO_DATE('2022-05-30','yyyy-mm-dd'));
insert into vai values(00545678,00045604, 19, TO_DATE('2022-05-30','yyyy-mm-dd'));
insert into vai values(35000000,00045604, 19, TO_DATE('2022-05-30','yyyy-mm-dd'));
insert into vai values(93345568,00045604, 19, TO_DATE('2022-05-30','yyyy-mm-dd'));
insert into vai values(73398678,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(15999999,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(26376578,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(30123678,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(04340978,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(15979987,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(43345678,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(35000000,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(14345678,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(13366679,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(15994769,03456005, 18, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(15999999,02345006, 17, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(93345568,02345006, 17, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(15956999,02345006, 17, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(97345678,02345006, 17, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(53345678,02345006, 17, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(15999999,02345006, 19, TO_DATE('2022-01-10','yyyy-mm-dd'));
insert into vai values(53345678,02345006, 19, TO_DATE('2022-01-10','yyyy-mm-dd'));
insert into vai values(13345678,02345006, 19, TO_DATE('2022-01-10','yyyy-mm-dd'));
insert into vai values(43345678,02345006, 19, TO_DATE('2022-01-10','yyyy-mm-dd'));
insert into vai values(15999999,02345006, 18, TO_DATE('2022-05-25','yyyy-mm-dd'));
insert into vai values(93345568,02345006, 18, TO_DATE('2022-05-25','yyyy-mm-dd'));
insert into vai values(14345678,02345006, 18, TO_DATE('2022-05-25','yyyy-mm-dd'));
insert into vai values(15987999,02345006, 18, TO_DATE('2022-05-25','yyyy-mm-dd'));
insert into vai values(13345688,02345006, 18, TO_DATE('2022-05-25','yyyy-mm-dd'));


insert into vai values(33345678,02345006, 9, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(15999999,02345006, 10, TO_DATE('2022-01-10','yyyy-mm-dd'));
insert into vai values(15999999,02345006, 11, TO_DATE('2022-01-25','yyyy-mm-dd'));
insert into vai values(15999999,02345006, 12, TO_DATE('2022-02-05','yyyy-mm-dd'));
insert into vai values(44345678,08363007, 18, TO_DATE('2022-04-10','yyyy-mm-dd'));
insert into vai values(15934569,00231008, 20, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(15934569,00231008, 18, TO_DATE('2022-01-10','yyyy-mm-dd'));
insert into vai values(15999999,00231008, 16, TO_DATE('2022-01-25','yyyy-mm-dd'));
insert into vai values(44345678,00231008, 17, TO_DATE('2022-02-05','yyyy-mm-dd'));
insert into vai values(08345908,00231008, 11, TO_DATE('2022-04-05','yyyy-mm-dd'));
insert into vai values(22127678,00231008, 13, TO_DATE('2022-05-25','yyyy-mm-dd'));
insert into vai values(13345698,00023349, 20, TO_DATE('2022-01-05','yyyy-mm-dd'));
insert into vai values(90345608,00023349, 19, TO_DATE('2022-01-10','yyyy-mm-dd'));
insert into vai values(15999999,10345010, 10, TO_DATE('2022-01-10','yyyy-mm-dd'));