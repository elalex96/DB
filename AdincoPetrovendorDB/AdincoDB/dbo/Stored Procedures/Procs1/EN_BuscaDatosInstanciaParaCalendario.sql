USE Adinco

GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_BuscaDatosInstanciaParaCalendario'
)
    DROP PROCEDURE EN_BuscaDatosInstanciaParaCalendario;
GO 

-- =============================================  
-- Author:  Reyna Olvera  
-- Create date: 20190104  
-- Description:Busca idContratoentregable y entregable  
-- =============================================  
-- =============================================  
-- Author:  Daniel   
-- Create date: 05/05/2020  
-- Description: Se agrego columnas de awareness 
-- =============================================  
CREATE  PROCEDURE [dbo].[EN_BuscaDatosInstanciaParaCalendario] --10061,3,567960  
    @idUsuario INT,  
    @idContrato INT,  
    @idInstanciaEntregable INT  
AS  
BEGIN  
  
    SET NOCOUNT ON;  
 SET LANGUAGE Spanish;   
    SELECT 
	idInstanciaEntregable,  
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
   CASE ISNULL(EN.bitMostrarMensaje,0) WHEN 1 THEN  
		DATEADD(MONTH,-1, IE.FechaCalculadaEntregaReg)  
	ELSE  
		IE.FechaCalculadaEntregaReg  
   END AS MesReportar,    
   CASE   
    WHEN ISNULL(CEPIA.IdContratoEntregable,0) > 1 THEN 
		1  
	ELSE 
		0  
   END AS BitSasisopa,  
   EN.Observaciones,  
   CASE WHEN ISNULL(CC.NombreContratista,'') LIKE '%Shell%' 
		AND  ISNULL(EN.BitAwareness,0)=1 THEN 
	1
   ELSE 
	0
   END AS bitAwareness,
   'Please confirm acknowledgement and understanding of the obligation(s) to which you have either been named as the accountable or responsible party.' AS mensajeAwareness
   FROM dbo.EN_InstanciasEntregable IE  
	JOIN  EN_ContratoEntregable CE  
			ON IE.IdContratoEntregable	=	CE.IdContratoEntregable  
	JOIN EN_Entregable EN  
			ON CE.IdEntregable			=	EN.IdEntregable  
	LEFT JOIN EN_MarcoLegal MA  
			ON EN.IdMarcoLegal			=	MA.IdMarcoLegal  
	LEFT JOIN EN_ContratoEntregableProgramaImplementaAcciones CEPIA  
			ON CE.IdContratoEntregable	=	CEPIA.IdContratoEntregable  
	LEFT JOIN CO_Contrato C
			ON CE.IdContrato			=	C.IdContrato
	LEFT JOIN CO_Contratista  CC  
			ON C.IdContratista			=	CC.IdContratista
    WHERE   
			idInstanciaEntregable = @idInstanciaEntregable;  
    
END;  