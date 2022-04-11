USE adinco
GO
DROP PROCEDURE IF EXISTS sp_EN_ExtraeDocumentosEntregablesSasisopa
GO
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 10/Marzo/2022
-- Description:	Se cambia la longitud de caracteres a 50
-- =============================================
CREATE PROCEDURE dbo.sp_EN_ExtraeDocumentosEntregablesSasisopa --3,10061,'2020-01-01','2020-07-30'
    @IdContrato INT,
    @idUsuario INT,
	@FechaInicio DATETIME,
	@FechaFin	DATETIME
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE Spanish; 

SELECT DISTINCT
	C.NumeroContrato	AS Contrato,
	PIT.Id AS IdPrograma,
	PIP.IdProgramaImplementaPolitica AS IdPolitica,
	PIE.IdProgramaImplementaElemento AS IdElemento,
	PIA.IdProgramaImplementaAccion AS IdAccion,
	IE.IdInstanciaEntregable,
	SUBSTRING( REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(PIT.Descripcion)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?',''),'"',''),0,30) AS NombrePrograma,
	SUBSTRING( REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(PIP.Descripcion)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?',''),'"',''),0,30) AS Politica, 
	SUBSTRING( REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(PIE.Descripcion)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?',''),'"',''),0,30) AS Elemento,
	SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(PIA.Descripcion)),CHAR(9),''),CHAR(13),''), '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?',''),'"',''),0,30) AS Accion,
	IE.FechaCalculadaEntregaReg	AS	FechaEstimadaEntregaRegulador
FROM
	CO_ProgramaImplementa	CPI
JOIN
	CO_Contrato	C	(NOLOCK)
	ON	CPI.IdContrato	=	C.IdContrato
JOIN
	CO_ProgramaImplementacionTipo	PIT
	ON	CPI.IdTipoPrograma = PIT.Id
	AND CPI.Activo	=	1
	AND CPI.IdContrato	=	PIT.IdContrato
JOIN
	CO_ProgramaImplementaPoliticas	PIP
	ON	CPI.IdProgramaImplementa	=	PIP.IdProgramaImplementa
JOIN
	CO_ProgramaImplementaElemento	PIE
	ON	PIP.IdProgramaImplementaPolitica = PIE.IdProgramaImplementaPolitica
JOIN
	CO_ProgramaImplementaAcciones	PIA
	ON	PIE.IdProgramaImplementaElemento = PIA.IdProgramaImplementaElemento
JOIN
	EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC
	ON	PIA.IdProgramaImplementaAccion = ENT_ACC.IdProgramaImplementaAccion
JOIN
	EN_ContratoEntregable	CE	(NOLOCK)
	ON	ENT_ACC.IdContratoEntregable	=	CE.IdContratoEntregable
	AND	ISNULL(ENT_ACC.Activo,1)	=	1
	AND	ISNULL(CE.Activo,1)	=	1
JOIN
	EN_InstanciasEntregable	IE (NOLOCK)
	ON	CE.IdContratoEntregable = IE.IdContratoEntregable
	AND	ISNULL(IE.Activo,1)	=	1
JOIN
	EN_HistorialAprobacionesLineaTiempo	FINR	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	FINR.idInstanciaEntregable
	AND FINR.idTipoOperacion = 4
JOIN
	EN_DocumentoVersion	DV
	ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
	AND DV.Activo = 1
WHERE
	PIT.IdContrato	=	@IdContrato
	AND
		IE.FechaCalculadaEntregaReg between  @FechaInicio AND @FechaFin;
END
