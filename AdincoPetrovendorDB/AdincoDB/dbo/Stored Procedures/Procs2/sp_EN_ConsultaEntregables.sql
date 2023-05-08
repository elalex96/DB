CREATE PROCEDURE [dbo].[sp_EN_ConsultaEntregables] 
	-- Add the parameters for the stored procedure here
@IdRegulador  INT = 0,
@IdFrecuencia INT = 0,
@IdContrato   INT,
@IdUsuario    INT
AS
     BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

	   --1	CIEP	Contrato Integral de Exploración y Producción	
	   --2	Producción Compartida	
	   --3	Licencia	
	   --4	Utilidad Compartida	
	   --5	Producción Compartida Farmouts		
	   --6	Licencia Farmouts		



    -- Insert statements for procedure here
         IF @IdRegulador <> 5
             BEGIN
                 SELECT E.IdEntregable,
                        E.Consecutivo,
                        ML.MarcoLegal,
                        E.TituloAnexo,
                        E.Capitulo,
                        E.Articulo,
                        E.DocumentoEntregable,
                        EN_FrecuenciaEntregable.FrecuenciaEntregable,
                        CO_Regulador.Regulador
                 FROM EN_Entregable AS E
                      INNER JOIN EN_MarcoLegal AS ML ON E.IdMarcoLegal = ML.IdMarcoLegal
						AND E.BITJOA = 0
                      INNER JOIN EN_FrecuenciaEntregable ON E.IdFrecuenciaEntregable = EN_FrecuenciaEntregable.IdFrecuenciaEntregable
                      INNER JOIN CO_Regulador ON E.IdRegulador = CO_Regulador.IdRegulador
                 WHERE(E.IdRegulador = @IdRegulador)
                      AND (E.IdFrecuenciaEntregable = @IdFrecuencia);
         END;
             ELSE
             BEGIN
                 SELECT E.IdEntregable,
			  E.Consecutivo,
                        ML.MarcoLegal,
                        E.TituloAnexo,
                        E.Capitulo,
                        E.Articulo,
                        E.DocumentoEntregable,
                        EN_FrecuenciaEntregable.FrecuenciaEntregable,
                        CO_Regulador.Regulador
                 FROM EN_Entregable AS E
                      INNER JOIN EN_MarcoLegal AS ML ON E.IdMarcoLegal = ML.IdMarcoLegal
						AND E.BITJOA = 0
                      INNER JOIN EN_FrecuenciaEntregable ON E.IdFrecuenciaEntregable = EN_FrecuenciaEntregable.IdFrecuenciaEntregable
                      INNER JOIN CO_Regulador ON E.IdRegulador = CO_Regulador.IdRegulador
         END;
     END;