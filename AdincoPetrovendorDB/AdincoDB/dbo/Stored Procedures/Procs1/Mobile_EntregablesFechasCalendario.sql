CREATE PROCEDURE [dbo].[Mobile_EntregablesFechasCalendario]
   @IdContrato AS INT,
	@IdUsuarioParam AS INT,
	@IdStatusEn AS int
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN

	CREATE TABLE [#FechasFinal]
	(
	[DocumentoEntregable] NVARCHAR(MAX),
	[Regulador] NVARCHAR(MAX),
	[LogoRegulador] NVARCHAR(MAX),
	[AnioI] INT,
	[MesI] INT,
	[DiaI] INT ,
	[AnioF] INT,
	[MesF] INT,
	[DiaF] INT
	)
	
	----------------------------------------------------------------
	----------------- CONTRATOS
	----------------------------------------------------------------
	SELECT distinct    
		CO_Contrato.IdContrato
		INTO #ContratosPorUsuario                 
		FROM            AP_PerfilUsuario AS PU INNER JOIN
								 AP_Usuario ON PU.UsuarioID = AP_Usuario.UsuarioID INNER JOIN
								 AP_Perfil ON PU.PerfilID = AP_Perfil.IdPerfil INNER JOIN
								 AP_Rol ON AP_Perfil.IdRol = AP_Rol.IdRol INNER JOIN
								 CO_Contrato ON AP_Perfil.IdContrato = CO_Contrato.IdContrato INNER JOIN
								 CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
		WHERE        (@IdUsuarioParam = PU.UsuarioID)
	---------------------------------------------------------------
				CREATE TABLE #TempInstancias (id INT PRIMARY KEY IDENTITY(1, 1),
											  IdContrato	INT,
											  FechasLimiteElaboracion DATE,
											  idInstanciasEntregables INT,
											  idEntregable INT,
											  idFrecuenciaE INT);

				INSERT INTO #TempInstancias (IdContrato,
											 FechasLimiteElaboracion,
											 idInstanciasEntregables,
											 idEntregable,
											 idFrecuenciaE)
				SELECT C.IdContrato,
					   MIN(IE.FechasLimiteElaboracion),
					   MIN(IE.idInstanciaEntregable) AS idInstancia,
					   CE.IdEntregable,
					   EN.IdFrecuenciaEntregable
				  FROM EN_InstanciasEntregable IE
				  JOIN EN_ContratoEntregable CE
					ON CE.IdContratoEntregable  = IE.IdContratoEntregable
				  JOIN dbo.EN_Actividad
					ON EN_Actividad.ActividadID = IE.ActividadID
				  JOIN dbo.EN_Estado
					ON EN_Estado.EstadoID       = EN_Actividad.EstadoID
				  JOIN CO_Contrato C
					ON C.IdContrato             = CE.IdContrato
				  JOIN EN_Entregable EN
					ON EN.IdEntregable          = CE.IdEntregable
					AND EN.BITJOA = 0
				  JOIN dbo.EN_FrecuenciaEntregable f
					ON f.IdFrecuenciaEntregable = EN.IdFrecuenciaEntregable
				 JOIN #ContratosPorUsuario	ConUs
					ON CE.IdContrato          = ConUs.IdContrato
				 WHERE EN_Actividad.idUsuario = @IdUsuarioParam
				   AND EN_Actividad.EstadoID=10000
				 GROUP BY C.IdContrato,
						  CE.IdEntregable,
						  EN.IdFrecuenciaEntregable;

				INSERT INTO #FechasFinal
				(
				    DocumentoEntregable,
				    Regulador,
				    LogoRegulador,
				    AnioI,
				    MesI,
				    DiaI,
				    AnioF,
				    MesF,
				    DiaF
				)
				SELECT
					DocumentoEntregable,
					R.Regulador AS Regulador,
					R.LogoRegulador,
					YEAR(IE.FechasLimiteElaboracion) AS [AnioI],
					MONTH(IE.FechasLimiteElaboracion) AS [MesI],
					DAY(IE.FechasLimiteElaboracion) AS [DiaI],

					YEAR(FechasLimiteAprobacion) AS [AnioF],
					MONTH(FechasLimiteAprobacion) AS [MesF],
					DAY(FechasLimiteAprobacion) AS [DiaF]
					---------------------
				  FROM EN_InstanciasEntregable IE
				  JOIN EN_ContratoEntregable CE
					ON CE.IdContratoEntregable    = IE.IdContratoEntregable
				  JOIN EN_Entregable EN
					ON EN.IdEntregable            = CE.IdEntregable
					AND EN.BITJOA = 0
				  JOIN dbo.CO_Regulador R
					ON R.IdRegulador              = EN.IdRegulador
				  JOIN #TempInstancias TI
					ON TI.idInstanciasEntregables = IE.idInstanciaEntregable
				 ORDER BY IE.FechasLimiteElaboracion ASC;		
				 ---------------------------------------
				 --SE SELECCIONAN LAS FECHAS PARA EL CONTROL
				 SELECT * FROM [#FechasFinal]
END