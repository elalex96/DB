CREATE PROCEDURE [dbo].[Mobile_EntregablesUsuario]-- 3,10061,10000 
@IdContrato AS int,
@IdUsuarioParam AS int,
@IdStatusEn AS int
-- WITH ENCRYPTION, R<ECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
begin
	SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#TempInstancias') IS NOT NULL
        DROP TABLE #TempInstancias;
--------------------------------Contratos por usuario
	create table #ContratosUsuario
	(
		IdContrato int
	)

	create table #EntregablesPorAprobar
	(
		countl int,
		IdEntregable int,
		IdContratoEntregable int,
		IdInstanciaEntegable int ,
		DocumentoEntregable varchar(1000),
		FechalimiteAprobacion date,
		Consecutivo varchar(1000),
		MarcoLegal varchar(1000),
		TituloAnexo varchar(1000),
		Capitulo varchar(1000),
		FrecuenciaEntregable varchar(1000),
		Regulador varchar(1000),
		Etapa varchar(1000),
		FechaCalculadaEntregaReg varchar(1000)
	)


	insert into #ContratosUsuario
	SELECT distinct    
	CO_Contrato.IdContrato
	FROM            AP_PerfilUsuario AS PU INNER JOIN
							 AP_Usuario ON PU.UsuarioID = AP_Usuario.UsuarioID INNER JOIN
							 AP_Perfil ON PU.PerfilID = AP_Perfil.IdPerfil INNER JOIN
							 AP_Rol ON AP_Perfil.IdRol = AP_Rol.IdRol INNER JOIN
							 CO_Contrato ON AP_Perfil.IdContrato = CO_Contrato.IdContrato INNER JOIN
							 CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
	WHERE        (@IdUsuarioParam = PU.UsuarioID)
------------------------ Llama SP Barbara/Reyna 

--WHILE
	DECLARE @IdContratoCursor AS nvarchar(400) --Sustituirá al IdProveedor en el cursor
	BEGIN
		DECLARE CursorContrato CURSOR FOR SELECT DISTINCT(IdContrato) FROM #ContratosUsuario
	END
	OPEN CursorContrato

	FETCH NEXT FROM CursorContrato INTO @IdContratoCursor

	WHILE @@fetch_status = 0

	BEGIN
	------------------------------------------------------------------------------------
	insert into #EntregablesPorAprobar
	exec en_entregablesaprobar @IdUsuarioParam ,@IdContratoCursor
	------------------------------------------------------------------------------------
	FETCH NEXT FROM CursorContrato INTO @IdContratoCursor
	END 
	CLOSE CursorContrato
	DEALLOCATE CursorContrato
--ENDWHILE
-----------------------------------------------------------

	select 
		Tp.IdEntregable,Tp.idInstanciaEntegable as idInstanciaEntregable,
		Tp.IdContratoEntregable, Tp.DocumentoEntregable, Tp.Regulador,
		isnull(R.LogoRegulador,'http://www.smbnation.com/components/com_easyblog/themes/wireframe/images/placeholder-image.png') as LogoRegulador,
		Tp.FrecuenciaEntregable as FrecuenciaEntregable,
		CONVERT(date, IE.FechasLimiteElaboracion, 1) as FechasLimiteElaboracion, 
		CONVERT(date, IE.FechasLimiteRevision , 1) as FechasLimiteRevision,
		CONVERT(date, IE.FechasLimiteAprobacion, 1) as FechasLimiteAprobacion,
		Tp.Consecutivo, Tp.MarcoLegal, Tp.TituloAnexo, Tp.Capitulo,
		ISNULL(AR.NombreArea,'-') as AreaResponsable,10002 as Estatus,
		dbo.fnGetElaboradoresEntregable(Tp.IdContratoEntregable) as 'Elaboradores',
		dbo.fnGetRevisoresEntregable (Tp.IdContratoEntregable) as 'Revisores',
		dbo.fnGetAprobadoresEntregable(Tp.IdContratoEntregable) as 'Aprobadores',
		'En Aprobación' as Estado,
		----
		isnull(Adinco.dbo.fnGetFechaElaboraRevisa(Tp.idInstanciaEntegable,2),'-') as 'FechaElaborada',
		isnull(Adinco.dbo.fnGetFechaElaboraRevisa(Tp.idInstanciaEntegable,3),'-') as 'FechaRevisada'
	from #EntregablesPorAprobar Tp
	join EN_ContratoEntregable as CE on CE.IdContratoEntregable = Tp.IdContratoEntregable
	join EN_InstanciasEntregable as IE on IE.idinstanciaentregable = Tp.IdInstanciaEntegable
	left join Co_Regulador as R on R.Regulador = Tp.Regulador
	left join EN_Area as AR on AR.IdArea = CE.IdArea
 
end