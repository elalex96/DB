-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20190104
-- Description:Busca idContratoentregable y entregable
-- =============================================
CREATE PROCEDURE [dbo].[EN_BuscaDatosInstanciaParaCalendario] --10061,3,253226
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT
AS
BEGIN

    SET NOCOUNT ON;
	SET LANGUAGE Spanish; 
    SELECT idInstanciaEntregable,
           IdRegulador,
           CE.IdContratoEntregable AS IdContratoEntregable,
           EN.IdEntregable AS IdEntregable,
           DocumentoEntregable,
           FechasLimiteAprobacion,
		   FechasLimiteElaboracion,
		   ISNULL(MA.MarcoLegal,'') AS MarcoLegal,
		   ISNULL(EN.Articulo,'') AS Articulo,
		   FechaCalculadaEntregaReg,
		   ISNULL(EN.bitMostrarMensaje,0) as bitMostrarMensaje,
			CASE	ISNULL(EN.bitMostrarMensaje,0)
				WHEN	1
				THEN		DATEADD(MONTH,-1, IE.FechaCalculadaEntregaReg)
			ELSE
				IE.FechaCalculadaEntregaReg
			END	AS MesReportar,
			CASE 
				WHEN ISNULL(CEPIA.IdContratoEntregable,0) > 1
				THEN	1
			ELSE	0
			END	AS BitSasisopa,
			EN.Observaciones 
    FROM dbo.EN_InstanciasEntregable IE
        JOIN 
			dbo.EN_ContratoEntregable CE
			ON IE.IdContratoEntregable=CE.IdContratoEntregable
        JOIN 
			dbo.EN_Entregable EN
			ON CE.IdEntregable=EN.IdEntregable
		LEFT JOIN
			EN_MarcoLegal	MA
			ON EN.IdMarcoLegal	=	MA.IdMarcoLegal
		LEFT	JOIN
			EN_ContratoEntregableProgramaImplementaAcciones CEPIA
			ON CE.IdContratoEntregable	=	CEPIA.IdContratoEntregable
    WHERE 
		idInstanciaEntregable = @idInstanciaEntregable;


END;



