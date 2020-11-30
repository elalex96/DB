CREATE PROCEDURE dbo.BI_ConsultaEntregablesTableau
	@IdContrato	INT
AS
BEGIN

SET NOCOUNT ON

CREATE TABLE #ConfigEntregable
(
	IdEntregable INT,
	IdContratoEntregable	INT,
	Consecutivo VARCHAR(50),
	CantidadEntregables	INT,
	DiasElaboracion	INT,
	DiasRevision	INT,
	DiasAprobacion	INT,
	Regulador		VARCHAR(250),
	Area			VARCHAR(250),
	Elaborador		VARCHAR(250),
	Revisor			VARCHAR(500),
	Aprobador		VARCHAR(250),
	DocumentoEntregable VARCHAR(5000)
)

INSERT INTO #ConfigEntregable
(
	IdEntregable,
	IdContratoEntregable,
	Consecutivo,
	CantidadEntregables,
	DiasElaboracion,
	DiasRevision,
	DiasAprobacion,
	Regulador,
	Area,
	DocumentoEntregable
)
SELECT	E.IdEntregable, CE.IdContratoEntregable, E.Consecutivo, COUNT(DISTINCT IE.idInstanciaEntregable), 
	CE.DiasElaboracion, CE.DiasRevision, CE.DiasAprobacion,
	RE.ReceptorEntregable,
	A.NombreArea,
	E.DocumentoEntregable
FROM EN_InstanciasEntregable	IE
JOIN EN_ContratoEntregable	CE
	ON IE.IdContratoEntregable = CE.IdContratoEntregable
JOIN EN_Entregable	E
	ON CE.IdEntregable	=	E.IdEntregable
JOIN EN_ReceptorEntregable	RE
	ON E.IdReceptorEntregable	=	RE.IdReceptorEntregable
JOIN EN_Area	A
	ON CE.IdArea	=	A.IdArea
WHERE
	CE.IdContrato = @IdContrato
	AND  CE.Activo = 1
	AND E.IsActivo = 1
	AND E.BitJOA = 0
GROUP BY
	E.IdEntregable, CE.IdContratoEntregable, E.Consecutivo, CE.DiasElaboracion, CE.DiasRevision, CE.DiasAprobacion,
	RE.ReceptorEntregable,
	A.NombreArea, E.DocumentoEntregable

UPDATE CE
	SET Elaborador =  U.Nombre
FROM
	#ConfigEntregable	CE
JOIN
	EN_Actividad	A
	ON	CE.IdContratoEntregable	=	A.IdContratoEntregable
	AND A.Activo	=	1
	AND A.EstadoID	=	10000	-- ELABORADOR
JOIN
	AP_Usuario	U
	ON	A.idUsuario	=	U.UsuarioID

UPDATE CE
	SET Aprobador =  U.Nombre
FROM
	#ConfigEntregable	CE
JOIN
	EN_Actividad	A
	ON	CE.IdContratoEntregable	=	A.IdContratoEntregable
	AND A.Activo	=	1
	AND A.EstadoID	=	10003	-- APROBADOR
JOIN
	AP_Usuario	U
	ON	A.idUsuario	=	U.UsuarioID


UPDATE #ConfigEntregable
	SET Revisor = dbo.fnGetRevisoresEntregable(IdContratoEntregable)


SELECT
	DATEFROMPARTS(YEAR(IE.FechaCalculadaEntregaReg), MONTH(IE.FechaCalculadaEntregaReg),1)	AS Mes,
	IE.FechaCalculadaEntregaReg	as FechaEntregaRegulador,
	DATEDIFF(DAY, GETDATE(), IE.FechaCalculadaEntregaReg)	AS DiasParaRegulador,
	IE.FechasLimiteAprobacion	AS FechaEntregaInterna,
	DATEDIFF(DAY, GETDATE(), IE.FechasLimiteAprobacion)	AS DiasParaEntregaInterna,
	CE.Regulador,
	CE.Area,
	CE.Elaborador,
	'% ELABORACION',
	CE.Revisor,
	'% REVISION',
	CE.Aprobador,
	'% APROBACION',
	'Estatus entregable (Elaboración o corrección, Revisión, Aprobación, Aprobación con Acuse)',
	'Estado Color (A tiempo, En riesgo de retraso, Entrega Retrasada)',
	CE.DocumentoEntregable
FROM
	#ConfigEntregable	CE
JOIN
	EN_InstanciasEntregable	IE
	ON	CE.IdContratoEntregable	=	IE.IdContratoEntregable
WHERE
	IE.FechasLimiteAprobacion	<	DATEADD(YEAR,5,GETDATE())
ORDER BY
	IE.FechasLimiteAprobacion


END