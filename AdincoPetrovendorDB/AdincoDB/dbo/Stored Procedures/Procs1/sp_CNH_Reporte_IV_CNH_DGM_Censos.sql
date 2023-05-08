CREATE PROCEDURE [dbo].[sp_CNH_Reporte_IV_CNH_DGM_Censos]
	@Contrato		INT,
	@MesReporte		VARCHAR(25),	
	@IdUsuario		INT
AS
BEGIN
-- =============================================
-- Description:	Reporte de CNH IV_CNH_DGM_Censos (Censos de Medicion: Sistemas de Medicion, Tanques y Equipos de Autoconsumo)
-- -------------------------------------------------
-- FECHA	MODIFICÓ	COMENTARIO
-- -------------------------------------------------
-- 20180503	BAAC		Creación de sp
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #Tanques
(
	IdContrato	INT,
	IdSistema	INT,
	--Descripcion	VARCHAR(250),
	Marca	VARCHAR	(300),
	Modelo	VARCHAR	(300),
	NoSerie	VARCHAR	(300),
	TAG		VARCHAR	(300),
	TipoMedidor	VARCHAR	(300),
	Certificado	VARCHAR(250),
	Fecha	DATETIME,
	FechaProxima	DATETIME,
	IntervaloCalibracion	VARCHAR(250),
	InvervaloVerificacion	VARCHAR (250),
	IncertidumbreMagnitud	VARCHAR (250),
	Laboratorio	VARCHAR (250),
	EsAcreditado	BIT,
	PuertoDisponible	varchar(250),
	ConfiguracionPuerto	varchar(250),
	ProtocoloComunicacion	varchar(250),
	AreaRestringida	BIT,
	Observaciones	VARCHAR(5000),
	-- DATOS DE RADAR/CINTA
	IdSistemaRC	INT,
	MarcaRC	VARCHAR	(300),
	ModeloRC	VARCHAR	(300),
	NoSerieRC	VARCHAR	(300),
	TAGRC		VARCHAR	(300),
	CertificadoRC	VARCHAR(250),
	FechaRC	DATETIME,
	FechaProximaRC	DATETIME,
	IntervaloCalibracionRC	VARCHAR(250),
		-- DATOS DE RTD/SENSOR
	IdSistemaRS	INT,
	MarcaRS	VARCHAR	(300),
	ModeloRS	VARCHAR	(300),
	NoSerieRS	VARCHAR	(300),
	TAGRS		VARCHAR	(300),
	CertificadoRS	VARCHAR(250),
	FechaRS	DATETIME,
	FechaProximaRS	DATETIME,
	IntervaloCalibracionRS	VARCHAR(250)
)

CREATE TABLE #Sistemas
(
	IdContrato	INT,
	--Id	INT IDENTITY(1,1),
	IdSistema	INT,
	--Descripcion	VARCHAR(250),
	Marca	VARCHAR	(300),
	Modelo	VARCHAR	(300),
	NoSerie	VARCHAR	(300),
	TAG		VARCHAR	(300),
	TipoMedidor	VARCHAR	(300),
	Certificado	VARCHAR(250),
	Fecha	DATETIME,
	FechaProxima	DATETIME,
	IntervaloCalibracion	VARCHAR(250),
	InvervaloVerificacion	VARCHAR (250),
	IncertidumbreMagnitud	VARCHAR (250),
	Laboratorio	VARCHAR (250),
	EsAcreditado	BIT,
	PuertoDisponible	varchar(250),
	ConfiguracionPuerto	varchar(250),
	ProtocoloComunicacion	varchar(250),
	AreaRestringida	BIT,
	IdSistema2	INT,
	Marca2	VARCHAR	(300),
	Modelo2	VARCHAR	(300),
	NoSerie2	VARCHAR	(300),
	TAG2		VARCHAR	(300),
	TipoMedidor2	VARCHAR	(300),
	Certificado2	VARCHAR(250),
	Fecha2	DATETIME,
	FechaProxima2	DATETIME,
	IntervaloCalibracion2	VARCHAR(250),
	InvervaloVerificacion2	VARCHAR (250),
	IncertidumbreMagnitud2	VARCHAR (250),
	Laboratorio2	VARCHAR (250),
	EsAcreditado2	BIT,
	PuertoDisponible2	varchar(250),
	ConfiguracionPuerto2	varchar(250),
	ProtocoloComunicacion2	varchar(250),
	AreaRestringida2	BIT,
	IdSistema3	INT,
	Marca3	VARCHAR	(300),
	Modelo3	VARCHAR	(300),
	NoSerie3	VARCHAR	(300),
	TAG3		VARCHAR	(300),
	TipoMedidor3	VARCHAR	(300),
	Certificado3	VARCHAR(250),
	Fecha3	DATETIME,
	FechaProxima3	DATETIME,
	IntervaloCalibracion3	VARCHAR(250),
	InvervaloVerificacion3	VARCHAR (250),
	IncertidumbreMagnitud3	VARCHAR (250),
	Laboratorio3	VARCHAR (250),
	EsAcreditado3	BIT,
	PuertoDisponible3	varchar(250),
	ConfiguracionPuerto3	varchar(250),
	ProtocoloComunicacion3	varchar(250),
	AreaRestringida3	BIT,
	IdSistema4	INT,
	Marca4	VARCHAR	(300),
	Modelo4	VARCHAR	(300),
	NoSerie4	VARCHAR	(300),
	TAG4		VARCHAR	(300),
	TipoMedidor4	VARCHAR	(300),
	Certificado4	VARCHAR(250),
	Fecha4	DATETIME,
	FechaProxima4	DATETIME,
	IntervaloCalibracion4	VARCHAR(250),
	InvervaloVerificacion4	VARCHAR (250),
	IncertidumbreMagnitud4	VARCHAR (250),
	Laboratorio4	VARCHAR (250),
	EsAcreditado4	BIT,
	PuertoDisponible4	varchar(250),
	ConfiguracionPuerto4	varchar(250),
	ProtocoloComunicacion4	varchar(250),
	AreaRestringida4	BIT,
	IdSistema5	INT,
	Marca5	VARCHAR	(300),
	Modelo5	VARCHAR	(300),
	NoSerie5	VARCHAR	(300),
	TAG5		VARCHAR	(300),
	TipoMedidor5	VARCHAR	(300),
	Certificado5	VARCHAR(250),
	Fecha5	DATETIME,
	FechaProxima5	DATETIME,
	IntervaloCalibracion5	VARCHAR(250),
	InvervaloVerificacion5	VARCHAR (250),
	IncertidumbreMagnitud5	VARCHAR (250),
	Laboratorio5	VARCHAR (250),
	EsAcreditado5	BIT,
	PuertoDisponible5	varchar(250),
	ConfiguracionPuerto5	varchar(250),
	ProtocoloComunicacion5	varchar(250),
	AreaRestringida5	BIT,
	IdSistema6	INT,
	Marca6	VARCHAR	(300),
	Modelo6	VARCHAR	(300),
	NoSerie6	VARCHAR	(300),
	TAG6		VARCHAR	(300),
	TipoMedidor6	VARCHAR	(300),
	Certificado6	VARCHAR(250),
	Fecha6	DATETIME,
	FechaProxima6	DATETIME,
	IntervaloCalibracion6	VARCHAR(250),
	InvervaloVerificacion6	VARCHAR (250),
	IncertidumbreMagnitud6	VARCHAR (250),
	Laboratorio6	VARCHAR (250),
	EsAcreditado6	BIT,
	PuertoDisponible6	varchar(250),
	ConfiguracionPuerto6	varchar(250),
	ProtocoloComunicacion6	varchar(250),
	AreaRestringida6	BIT,
	IdSistema7	INT,
	Marca7	VARCHAR	(300),
	Modelo7	VARCHAR	(300),
	NoSerie7	VARCHAR	(300),
	TAG7		VARCHAR	(300),
	TipoMedidor7	VARCHAR	(300),
	Certificado7	VARCHAR(250),
	Fecha7	DATETIME,
	FechaProxima7	DATETIME,
	IntervaloCalibracion7	VARCHAR(250),
	InvervaloVerificacion7	VARCHAR (250),
	IncertidumbreMagnitud7	VARCHAR (250),
	Laboratorio7	VARCHAR (250),
	EsAcreditado7	BIT,
	PuertoDisponible7	varchar(250),
	ConfiguracionPuerto7	varchar(250),
	ProtocoloComunicacion7	varchar(250),
	AreaRestringida7	BIT,
	IdSistema8	INT,
	Marca8	VARCHAR	(300),
	Modelo8	VARCHAR	(300),
	NoSerie8	VARCHAR	(300),
	TAG8		VARCHAR	(300),
	TipoMedidor8	VARCHAR	(300),
	Certificado8	VARCHAR(250),
	Fecha8	DATETIME,
	FechaProxima8	DATETIME,
	IntervaloCalibracion8	VARCHAR(250),
	InvervaloVerificacion8	VARCHAR (250),
	IncertidumbreMagnitud8	VARCHAR (250),
	Laboratorio8	VARCHAR (250),
	EsAcreditado8	BIT,
	PuertoDisponible8	varchar(250),
	ConfiguracionPuerto8	varchar(250),
	ProtocoloComunicacion8	varchar(250),
	AreaRestringida8	BIT,
	Observaciones	VARCHAR(5000)
)

CREATE TABLE #Contratos
(
	IdContrato	INT PRIMARY KEY
)

CREATE TABLE #Puntos
(
	IdContrato	INT,
	Nombre		VARCHAR(250)
)

CREATE TABLE #PuntosXContrato
(
	IdContrato	INT,
	PuntosEntrega		VARCHAR(3000),
	PRIMARY KEY (IdContrato)
)

DECLARE @PuntosMedicion VARCHAR(3000) = '',
		@Mes			DATE,
		@IdRelacionado	INT

SELECT @Mes = DATEFROMPARTS( SUBSTRING( @MesReporte, 7, 4 ), SUBSTRING( @MesReporte, 4, 2 ), SUBSTRING( @MesReporte, 1, 2 ) )

--SELECT
--	@IdRelacionado	=	REL.IdRelacionado
--FROM
--	dbo.CO_Contrato	C
--JOIN
--	CO_ContratistaRelacionado	REL
--	ON	C.IdContratista	=	REL.IdContratista
--WHERE
--	C.IdContrato = @Contrato

---- SI NO HAY CONTRATISTAS RELACIONADOS, SE INSERTAN TODOS LOS CONTRATOS DEL MISMO SUBCONTRATISTA	
--IF ISNULL(@IdRelacionado,0) = 0
--BEGIN
	INSERT INTO #Contratos
	(
	    IdContrato
	)
	SELECT
		C2.IdContrato
	FROM
		dbo.CO_Contrato	C
	JOIN
		dbo.CO_Contrato	C2
		ON	C.IdContratista	=	C2.IdContratista
	WHERE
		C.IdContrato	=	@Contrato
--END
--ELSE
--BEGIN
--	INSERT INTO #Contratos
--	(
--	    IdContrato
--	)
--	SELECT
--		C.IdContrato
--	FROM
--		dbo.CO_Contrato	C
--	JOIN
--		CO_ContratistaRelacionado	REL
--		ON	C.IdContratista	=	REL.IdContratista
--	WHERE
--		REL.IdRelacionado	=	@IdRelacionado
--END

INSERT INTO #Puntos
(
	IdContrato,
	Nombre
)
SELECT
	CO.IdContrato,
	PE.Nombre
FROM
	#Contratos	CO
JOIN
	dbo.CO_Contrato	C
	ON	CO.IdContrato	=	C.IdContrato
JOIN
	CO_Instalacion	I
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	C.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
JOIN
	dbo.CO_PuntosdeEntrega	PE
	ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
--WHERE
--	C.IdContrato	=	@Contrato
GROUP BY
	CO.IdContrato,
	PE.Nombre

INSERT INTO #PuntosXContrato
(
	IdContrato,
	PuntosEntrega
)
SELECT
	B.IdContrato , 
	STUFF(( SELECT  ', '+ Nombre FROM #Puntos A
			WHERE B.IdContrato = A.IdContrato  FOR XML PATH('')),1 ,1, '')  Members
FROM
	#Puntos B
GROUP BY
	B.IdContrato

INSERT INTO #Tanques
(
	IdContrato,
    IdSistema,
    Marca,
    Modelo,
    NoSerie,
    TAG,
    TipoMedidor
)
SELECT
	CO.IdContrato,
	SM.IdSistema,
	ISNULL(Marca,''),
	ISNULL(Modelo,''),
	ISNULL(NoSerie,''),
	ISNULL(TAG,''),
	ISNULL(SM.TipoMedidor,'')
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS
	ON	SM.IdTipoSistema	=	TS.IdTipoSistema
	AND	TS.Activo	=	1
	AND TS.Orden	=	9
	AND SM.Activo	=	1
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET	IdSistemaRC	=	SM.IdSistema,
    MarcaRC		=	SM.Marca,
    ModeloRC		=	SM.Modelo,
    NoSerieRC	=	SM.NoSerie,
    TAGRC		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS2
	ON	SM.IdTipoSistema	=	TS2.IdTipoSistema
	AND	TS2.Activo	=	1
	AND TS2.Orden	=	10
	AND SM.Activo	=	1
JOIN
	#Tanques	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET	IdSistemaRS	=	SM.IdSistema,
    MarcaRS		=	SM.Marca,
    ModeloRS		=	SM.Modelo,
    NoSerieRS	=	SM.NoSerie,
    TAGRS		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS2
	ON	SM.IdTipoSistema	=	TS2.IdTipoSistema
	AND	TS2.Activo	=	1
	AND TS2.Orden	=	11
	AND SM.Activo	=	1
JOIN
	#Tanques	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato
	
		
INSERT INTO #Sistemas
(
	IdContrato,
    IdSistema,
    Marca,
    Modelo,
    NoSerie,
    TAG,
    TipoMedidor
)
SELECT
	CO.IdContrato,
	SM.IdSistema,
	ISNULL(Marca,''),
	ISNULL(Modelo,''),
	ISNULL(NoSerie,''),
	ISNULL(TAG,''),
	CASE WHEN TS.Descripcion = 'Elemento Primario' THEN ISNULL(SM.TipoMedidor,'')
		ELSE NULL
	END
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS
	ON	SM.IdTipoSistema	=	TS.IdTipoSistema
	AND	TS.Activo	=	1
	AND TS.Orden	=	1
	AND SM.Activo	=	1
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET	IdSistema2	=	SM.IdSistema,
    Marca2		=	SM.Marca,
    Modelo2		=	SM.Modelo,
    NoSerie2	=	SM.NoSerie,
    TAG2		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS2
	ON	SM.IdTipoSistema	=	TS2.IdTipoSistema
	AND	TS2.Activo	=	1
	AND TS2.Orden	=	2
	AND SM.Activo	=	1
JOIN
	#Sistemas	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET	IdSistema3	=	SM.IdSistema,
    Marca3		=	SM.Marca,
    Modelo3		=	SM.Modelo,
    NoSerie3	=	SM.NoSerie,
    TAG3		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS3
	ON	SM.IdTipoSistema	=	TS3.IdTipoSistema
	AND	TS3.Activo	=	1
	AND TS3.Orden	=	3
	AND SM.Activo	=	1
JOIN
	#Sistemas	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET	IdSistema4	=	SM.IdSistema,
    Marca4		=	SM.Marca,
    Modelo4		=	SM.Modelo,
    NoSerie4	=	SM.NoSerie,
    TAG4		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
LEFT JOIN
	PR_TipoSistemaMedicion	TS4
	ON	SM.IdTipoSistema	=	TS4.IdTipoSistema
	AND	TS4.Activo	=	1
	AND TS4.Orden	=	4
	AND SM.Activo	=	1
JOIN
	#Sistemas	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET	IdSistema5	=	SM.IdSistema,
    Marca5		=	SM.Marca,
    Modelo5		=	SM.Modelo,
    NoSerie5	=	SM.NoSerie,
    TAG5		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS5
	ON	SM.IdTipoSistema	=	TS5.IdTipoSistema
	AND	TS5.Activo	=	1
	AND TS5.Orden	=	5
	AND SM.Activo	=	1
JOIN
	#Sistemas	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato


UPDATE	S
	SET	IdSistema6	=	SM.IdSistema,
    Marca6		=	SM.Marca,
    Modelo6		=	SM.Modelo,
    NoSerie6	=	SM.NoSerie,
    TAG6		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS6
	ON	SM.IdTipoSistema	=	TS6.IdTipoSistema
	AND	TS6.Activo	=	1
	AND TS6.Orden	=	6
	AND SM.Activo	=	1
JOIN
	#Sistemas	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET	IdSistema7	=	SM.IdSistema,
    Marca7		=	SM.Marca,
    Modelo7		=	SM.Modelo,
    NoSerie7	=	SM.NoSerie,
    TAG7		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS7
	ON	SM.IdTipoSistema	=	TS7.IdTipoSistema
	AND	TS7.Activo	=	1
	AND TS7.Orden	=	7
	AND SM.Activo	=	1
JOIN
	#Sistemas	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET	IdSistema8	=	SM.IdSistema,
    Marca8		=	SM.Marca,
    Modelo8		=	SM.Modelo,
    NoSerie8	=	SM.NoSerie,
    TAG8		=	SM.TAG
FROM
	#Contratos	CO
JOIN
	PR_SistemasMedicion	SM
	ON	CO.IdContrato	=	SM.IdContrato
JOIN
	PR_TipoSistemaMedicion	TS8
	ON	SM.IdTipoSistema	=	TS8.IdTipoSistema
	AND	TS8.Activo	=	1
	AND TS8.Orden	=	8
	AND SM.Activo	=	1
JOIN
	#Sistemas	S
	ON	CO.IdContrato	=	S.IdContrato
--WHERE
--	SM.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado		=	CS.Certificado,
		Fecha			=	CS.Fecha,
		FechaProxima	=	CS.FechaProxima,
		IntervaloCalibracion	=	CS.IntervaloCalibracion,
		InvervaloVerificacion	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud	=	CS.IncertidumbreMagnitud,
		Laboratorio				=	CS.Laboratorio,
		EsAcreditado			=	CS.EsAcreditado,
		PuertoDisponible		=	CS.PuertoDisponible,
		ConfiguracionPuerto		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion	=	CS.ProtocoloComunicacion,
		AreaRestringida			=	CS.AreaRestringida,
		Observaciones			=	CS.Observaciones
FROM
	#Tanques	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND	S.IdSistema	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		CertificadoRC		=	CS.Certificado,
		FechaRC			=	CS.Fecha,
		FechaProximaRC	=	CS.FechaProxima,
		IntervaloCalibracionRC	=	CS.IntervaloCalibracion,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Tanques	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND	S.IdSistemaRC	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		CertificadoRS		=	CS.Certificado,
		FechaRS			=	CS.Fecha,
		FechaProximaRS	=	CS.FechaProxima,
		IntervaloCalibracionRS	=	CS.IntervaloCalibracion,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Tanques	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND	S.IdSistemaRS	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado		=	CS.Certificado,
		Fecha			=	CS.Fecha,
		FechaProxima	=	CS.FechaProxima,
		IntervaloCalibracion	=	CS.IntervaloCalibracion,
		InvervaloVerificacion	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud	=	CS.IncertidumbreMagnitud,
		Laboratorio				=	CS.Laboratorio,
		EsAcreditado			=	CS.EsAcreditado,
		PuertoDisponible		=	CS.PuertoDisponible,
		ConfiguracionPuerto		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion	=	CS.ProtocoloComunicacion,
		AreaRestringida			=	CS.AreaRestringida,
		Observaciones			=	CS.Observaciones
FROM
	#Sistemas	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND	S.IdSistema	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado2		=	CS.Certificado,
		Fecha2			=	CS.Fecha,
		FechaProxima2	=	CS.FechaProxima,
		IntervaloCalibracion2	=	CS.IntervaloCalibracion,
		InvervaloVerificacion2	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud2	=	CS.IncertidumbreMagnitud,
		Laboratorio2				=	CS.Laboratorio,
		EsAcreditado2			=	CS.EsAcreditado,
		PuertoDisponible2		=	CS.PuertoDisponible,
		ConfiguracionPuerto2		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion2	=	CS.ProtocoloComunicacion,
		AreaRestringida2		=	CS.AreaRestringida,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Sistemas	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND S.IdSistema2	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado3		=	CS.Certificado,
		Fecha3			=	CS.Fecha,
		FechaProxima3	=	CS.FechaProxima,
		IntervaloCalibracion3	=	CS.IntervaloCalibracion,
		InvervaloVerificacion3	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud3	=	CS.IncertidumbreMagnitud,
		Laboratorio3				=	CS.Laboratorio,
		EsAcreditado3			=	CS.EsAcreditado,
		PuertoDisponible3		=	CS.PuertoDisponible,
		ConfiguracionPuerto3		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion3	=	CS.ProtocoloComunicacion,
		AreaRestringida3		=	CS.AreaRestringida,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Sistemas	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND S.IdSistema3	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado4		=	CS.Certificado,
		Fecha4			=	CS.Fecha,
		FechaProxima4	=	CS.FechaProxima,
		IntervaloCalibracion4	=	CS.IntervaloCalibracion,
		InvervaloVerificacion4	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud4	=	CS.IncertidumbreMagnitud,
		Laboratorio4				=	CS.Laboratorio,
		EsAcreditado4			=	CS.EsAcreditado,
		PuertoDisponible4		=	CS.PuertoDisponible,
		ConfiguracionPuerto4		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion4	=	CS.ProtocoloComunicacion,
		AreaRestringida4		=	CS.AreaRestringida,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Sistemas	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND S.IdSistema4	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado5		=	CS.Certificado,
		Fecha5			=	CS.Fecha,
		FechaProxima5	=	CS.FechaProxima,
		IntervaloCalibracion5	=	CS.IntervaloCalibracion,
		InvervaloVerificacion5	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud5	=	CS.IncertidumbreMagnitud,
		Laboratorio5				=	CS.Laboratorio,
		EsAcreditado5			=	CS.EsAcreditado,
		PuertoDisponible5		=	CS.PuertoDisponible,
		ConfiguracionPuerto5		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion5	=	CS.ProtocoloComunicacion,
		AreaRestringida5		=	CS.AreaRestringida,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Sistemas	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND S.IdSistema5	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado6		=	CS.Certificado,
		Fecha6			=	CS.Fecha,
		FechaProxima6	=	CS.FechaProxima,
		IntervaloCalibracion6	=	CS.IntervaloCalibracion,
		InvervaloVerificacion6	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud6	=	CS.IncertidumbreMagnitud,
		Laboratorio6				=	CS.Laboratorio,
		EsAcreditado6			=	CS.EsAcreditado,
		PuertoDisponible6		=	CS.PuertoDisponible,
		ConfiguracionPuerto6		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion6	=	CS.ProtocoloComunicacion,
		AreaRestringida6		=	CS.AreaRestringida,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Sistemas	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND S.IdSistema6	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado7		=	CS.Certificado,
		Fecha7			=	CS.Fecha,
		FechaProxima7	=	CS.FechaProxima,
		IntervaloCalibracion7	=	CS.IntervaloCalibracion,
		InvervaloVerificacion7	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud7	=	CS.IncertidumbreMagnitud,
		Laboratorio7				=	CS.Laboratorio,
		EsAcreditado7			=	CS.EsAcreditado,
		PuertoDisponible7		=	CS.PuertoDisponible,
		ConfiguracionPuerto7		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion7	=	CS.ProtocoloComunicacion,
		AreaRestringida7		=	CS.AreaRestringida,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Sistemas	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND S.IdSistema7	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

UPDATE	S
	SET
		Certificado8		=	CS.Certificado,
		Fecha8			=	CS.Fecha,
		FechaProxima8	=	CS.FechaProxima,
		IntervaloCalibracion8	=	CS.IntervaloCalibracion,
		InvervaloVerificacion8	=	CS.InvervaloVerificacion,
		IncertidumbreMagnitud8	=	CS.IncertidumbreMagnitud,
		Laboratorio8				=	CS.Laboratorio,
		EsAcreditado8			=	CS.EsAcreditado,
		PuertoDisponible8		=	CS.PuertoDisponible,
		ConfiguracionPuerto8		=	CS.ConfiguracionPuerto,
		ProtocoloComunicacion8	=	CS.ProtocoloComunicacion,
		AreaRestringida8		=	CS.AreaRestringida,
		Observaciones			=	S.Observaciones + CHAR(10) + CS.Observaciones
FROM
	#Sistemas	S
JOIN
	PR_CalibracionSistemas	CS
	ON	S.IdContrato	=	CS.IdContrato
	AND S.IdSistema8	=	CS.IdSistema
WHERE
	CS.Vigente	=	1
	--AND
	--CS.IdContrato	=	@Contrato

SELECT DISTINCT
	C.NumeroContrato	AS [ID Contrato o Asignación],
	P.RegionFiscal		AS [Región Fiscal],
	E.Estado			AS [Entidad Federativa],
	CA.Nombre		AS [Campo],
	--I.NombreInstalacion	AS [Instalación],
	--PE.Nombre			AS [Instalación],
	@PuntosMedicion		AS [Instalación],
	CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)	AS [Tipo de Fluido],
	PE.TipoMedidor		AS [Tipo de medición],
	I.UTMX				AS [Coordenada Geográfica X],
	I.UTMY				AS [Coordenada Geográfica Y],
	PE.TagPatinMedicion	AS [Tag del Patín de Medición],
	'Número de Trenes en el Patín de medición',
	PE.TagMedidor		AS [TAG del Tren de Medición],
	@PuntosMedicion		AS [Puntos de Medición de Acuerdo a Operación],
	PE.Clasificacion	AS [Clasificación del Patín de Medición],	
	'Incertidumbre como Tren de Medición',
	'Incertidumbre como Patín de Medición',
	'¿El patín de medición cuenta con telemetría?',
	S.TipoMedidor	AS	[Tipo de Medidor],
	S.Marca			AS [Marca],
	S.Modelo		AS [Modelo],
	S.NoSerie		AS [Numero de Serie],
	S.TAG			AS [TAG],
	S.Certificado	AS [No. De certificado de calibración],
	S.Fecha			AS [Fecha de Calibración],
	S.FechaProxima	AS [Fecha Próxima de Calibración],
	S.IntervaloCalibracion	AS [Intervalo de Calibración],
	S.InvervaloVerificacion	AS [Intervalo de Verificación],
	S.IncertidumbreMagnitud	AS [Incertidumbre asociada a la magnitud],
	S.Laboratorio	AS [Laboratorio de calibración],
	CASE WHEN ISNULL(S.EsAcreditado,0) = 1 THEN 'Si' ELSE 'No' END AS [¿El laboratorio está acreditado?],
--Transmisor de Temperatura
	S.Marca2			AS [Marca],
	S.Modelo2		AS [Modelo],
	S.NoSerie2		AS [Numero de Serie],
	S.TAG2			AS [TAG],
	S.Certificado2	AS [No. De certificado de calibración],
	S.Fecha2			AS [Fecha de Calibración],
	S.FechaProxima2	AS [Fecha Próxima de Calibración],
	S.IntervaloCalibracion2	AS [Intervalo de Calibración],
	S.InvervaloVerificacion2	AS [Intervalo de Verificación],
	S.IncertidumbreMagnitud2	AS [Incertidumbre asociada a la magnitud],
	S.Laboratorio2	AS [Laboratorio de calibración],
	CASE WHEN ISNULL(S.EsAcreditado2,0) = 1 THEN 'Si' ELSE 'No' END AS [¿El laboratorio está acreditado?],
--Transmisor de presión
	S.Marca3			AS [Marca],
	S.Modelo3		AS [Modelo],
	S.NoSerie3		AS [Numero de Serie],
	S.TAG3			AS [TAG],
	S.Certificado3	AS [No. De certificado de calibración],
	S.Fecha3			AS [Fecha de Calibración],
	S.FechaProxima3	AS [Fecha Próxima de Calibración],
	S.IntervaloCalibracion3	AS [Intervalo de Calibración],
	S.InvervaloVerificacion3	AS [Intervalo de Verificación],
	S.IncertidumbreMagnitud3	AS [Incertidumbre asociada a la magnitud],
	S.Laboratorio3	AS [Laboratorio de calibración],
	CASE WHEN ISNULL(S.EsAcreditado3,0) = 1 THEN 'Si' ELSE 'No' END AS [¿El laboratorio está acreditado?],
--Densitómetro/Cromatógrafo
	S.Marca4			AS [Marca],
	S.Modelo4		AS [Modelo],
	S.NoSerie4		AS [Numero de Serie],
	S.TAG4			AS [TAG],
	S.Certificado4	AS [No. De certificado de calibración],
	S.Fecha4			AS [Fecha de Calibración],
	S.FechaProxima4	AS [Fecha Próxima de Calibración],
	S.IntervaloCalibracion4	AS [Intervalo de Calibración],
	S.InvervaloVerificacion4	AS [Intervalo de Verificación],
	S.IncertidumbreMagnitud4	AS [Incertidumbre asociada a la magnitud],
	S.Laboratorio4	AS [Laboratorio de calibración],
	CASE WHEN ISNULL(S.EsAcreditado4,0) = 1 THEN 'Si' ELSE 'No' END AS [¿El laboratorio está acreditado?],
--Analizador de Corte de agua
	S.Marca5			AS [Marca],
	S.Modelo5		AS [Modelo],
	S.NoSerie5		AS [Numero de Serie],
	S.TAG5			AS [TAG],
	S.Certificado5	AS [No. De certificado de calibración],
	S.Fecha5			AS [Fecha de Calibración],
	S.FechaProxima5	AS [Fecha Próxima de Calibración],
	S.IntervaloCalibracion5	AS [Intervalo de Calibración],
	S.InvervaloVerificacion5	AS [Intervalo de Verificación],
	S.IncertidumbreMagnitud5	AS [Incertidumbre asociada a la magnitud],
	S.Laboratorio5	AS [Laboratorio de calibración],
	CASE WHEN ISNULL(S.EsAcreditado5,0) = 1 THEN 'Si' ELSE 'No' END AS [¿El laboratorio está acreditado?],
--Analizador de H2S
	S.Marca6			AS [Marca],
	S.Modelo6		AS [Modelo],
	S.NoSerie6		AS [Numero de Serie],
	S.TAG6			AS [TAG],
	S.Certificado6	AS [No. De certificado de calibración],
	S.Fecha6			AS [Fecha de Calibración],
	S.FechaProxima6	AS [Fecha Próxima de Calibración],
	S.IntervaloCalibracion6	AS [Intervalo de Calibración],
	S.InvervaloVerificacion6	AS [Intervalo de Verificación],
	S.IncertidumbreMagnitud6	AS [Incertidumbre asociada a la magnitud],
	S.Laboratorio6	AS [Laboratorio de calibración],
	CASE WHEN ISNULL(S.EsAcreditado6,0) = 1 THEN 'Si' ELSE 'No' END AS [¿El laboratorio está acreditado?],
--Analizador de Humedad
	S.Marca7			AS [Marca],
	S.Modelo7		AS [Modelo],
	S.NoSerie7		AS [Numero de Serie],
	S.TAG7			AS [TAG],
	S.Certificado7	AS [No. De certificado de calibración],
	S.Fecha7			AS [Fecha de Calibración],
	S.FechaProxima7	AS [Fecha Próxima de Calibración],
	S.IntervaloCalibracion7	AS [Intervalo de Calibración],
	S.InvervaloVerificacion7	AS [Intervalo de Verificación],
	S.IncertidumbreMagnitud7	AS [Incertidumbre asociada a la magnitud],
	S.Laboratorio7	AS [Laboratorio de calibración],
	CASE WHEN ISNULL(S.EsAcreditado7,0) = 1 THEN 'Si' ELSE 'No' END AS [¿El laboratorio está acreditado?],
--Computador de Flujo
	--''	AS [En caso de que se cuente con analizadores en línea refiérase a la nota 3],
	S.Marca8			AS [Marca],
	S.Modelo8		AS [Modelo],
	S.NoSerie8		AS [Numero de Serie],
	S.TAG8			AS [TAG],
	S.Certificado8	AS [No. De certificado de calibración],
	S.PuertoDisponible8	AS [Puerto Disponible],
	S.ConfiguracionPuerto8	AS [Configuración del Puerto],
	S.ProtocoloComunicacion8	AS [Protocolo de Comunicación],
	CASE WHEN ISNULL(S.AreaRestringida8,0) = 1 THEN 'Si' ELSE 'No' END AS [¿Se encuentra en área restringida?],
	S.Observaciones		AS [Observaciones]
FROM
	#Contratos	CO
JOIN
	dbo.CO_Contrato	C
	ON	CO.IdContrato	=	C.IdContrato
JOIN
	CO_AreaContractual	AC
	ON	C.IdAreaContractual	=	AC.IdAreaContractual
JOIN
	dbo.PV_EstadoRepublica	E
	ON	AC.IdEstado		=	E.idEstado
JOIN
	CO_Instalacion	I
	ON	AC.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	C.IdContrato	=	PEC.idContrato
JOIN
	dbo.CO_PuntosdeEntrega	PE
	ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	AND	P.PuntoEntregaID	=	PE.PuntoEntregaID
LEFT JOIN
	dbo.PR_Campo	CA
	ON	P.Campo	=	CA.Id
JOIN 
	#Sistemas	S
	ON	C.IdContrato	=	S.IdContrato
--WHERE
--	C.IdContrato	=	@Contrato
	
/**************************** TANQUES ********************/
SELECT DISTINCT
	C.NumeroContrato	AS [ID Contrato o Asignación],
	P.RegionFiscal		AS [Región Fiscal],
	E.Estado			AS [Entidad Federativa],
	CA.Nombre		AS [Campo],
	--I.NombreInstalacion	AS [Instalación],
	PE.Nombre			AS [Instalación],
	--@PuntosMedicion		AS [Instalación],
	I.UTMX				AS [Coordenada Geográfica X],
	I.UTMY				AS [Coordenada Geográfica Y],
	T.ProductoAlmacenado,
	S.IncertidumbreMagnitud	AS [Incertidumbre del sistema de medición],
	TT.Descripcion	AS [Tipo de Tanque],
	CASE WHEN T.MedicionManual = 1 THEN 'Manual' 
		ELSE 'Automático'
	END		AS [Tipo de medición],
	S.TAG,
	S.Certificado,
	S.Fecha,
	S.FechaProxima,
	S.IntervaloCalibracion,
	S.InvervaloVerificacion,
	S.IncertidumbreMagnitud,
	S.Laboratorio,
	CASE WHEN ISNULL(S.EsAcreditado,0) = 1 THEN 'Si' ELSE 'No' END AS [¿El laboratorio está acreditado?],
	/********* RADAR ***************/
	S.MarcaRC,
	S.ModeloRC,
	S.NoSerieRC,
	S.TAGRC,
	S.CertificadoRC,
	S.FechaRC,
	S.FechaProximaRC,
	S.IntervaloCalibracionRC,
	S.MarcaRS,
	S.ModeloRS,
	S.NoSerieRS,
	S.TAGRS,
	S.CertificadoRS,
	S.FechaRS,
	S.FechaProximaRS,
	S.IntervaloCalibracionRS,
	S.Observaciones
FROM
	#Contratos	CO
JOIN
	dbo.CO_Contrato	C
	ON	CO.IdContrato	=	C.IdContrato
JOIN
	CO_AreaContractual	AC
	ON	C.IdAreaContractual	=	AC.IdAreaContractual
JOIN
	dbo.PV_EstadoRepublica	E
	ON	AC.IdEstado		=	E.idEstado
JOIN
	CO_Instalacion	I
	ON	AC.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	C.IdContrato	=	PEC.idContrato
JOIN
	dbo.CO_PuntosdeEntrega	PE
	ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	AND	P.PuntoEntregaID	=	PE.PuntoEntregaID
JOIN
	dbo.PR_Tanque	T
	ON	PEC.PuntoEntregaID	=	T.PuntoEntregaID
JOIN
	PR_TiposTanques	TT
	ON	T.IdTipoTanque	=	TT.IdTipoTanque
LEFT JOIN
	dbo.PR_Campo	CA
	ON	P.Campo	=	CA.Id
JOIN 
	#Tanques	S
	ON	PEC.idContrato	=	S.IdContrato
--WHERE
--	C.IdContrato	=	@Contrato

/**************************** EQUIPOS DE AUTOCONSUMO ********************/

SELECT DISTINCT
	C.NumeroContrato	AS [ID Contrato o Asignación],
	P.RegionFiscal		AS [Región Fiscal],
	E.Estado			AS [Entidad Federativa],
	CA.Nombre		AS [Campo],
	--I.NombreInstalacion	AS [Instalación],
	PE.Nombre		AS [Instalación],
	A.UTMX				AS [Coordenada Geográfica X],
	A.UTMY				AS [Coordenada Geográfica Y],
	A.Producto,
	A.TipoEquipo,
	A.TAG,
	A.FluidoDesplazado,
	A.ConsumoTeorico,
	A.ConsumoReal,
	A.ConsumoEnergetico,
	A.DispositivoInyeccion,
	A.Obervaciones
FROM
	#Contratos	CO
JOIN
	dbo.CO_Contrato	C
	ON	CO.IdContrato	=	C.IdContrato
JOIN
	CO_AreaContractual	AC
	ON	C.IdAreaContractual	=	AC.IdAreaContractual
JOIN
	dbo.PV_EstadoRepublica	E
	ON	AC.IdEstado		=	E.idEstado
JOIN
	CO_Instalacion	I
	ON	AC.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	C.IdContrato	=	PEC.idContrato
JOIN
	dbo.CO_PuntosdeEntrega	PE
	ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	AND	P.PuntoEntregaID	=	PE.PuntoEntregaID
JOIN
	PR_EquiposAutoconsumo	A
	ON	C.IdContrato	=	A.IdContrato
LEFT JOIN
	dbo.PR_Campo	CA
	ON	P.Campo	=	CA.Id
--WHERE
--	C.IdContrato	=	@Contrato

END

