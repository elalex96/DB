
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 01-08-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_FormatoConsulta] 
	-- Add the parameters for the stored procedure here
@IdEntregable INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdEntregable,
                DocumentoEntregable,
                MarcoLegal,
                TituloAnexo,
                Capitulo,
                Descripcion,
                Seccion,
                Articulo,
                Inciso,
                Apartado,
                Observaciones,
                ArchivoNormatividad,
                ArchivoEntregable,
                Regulador,
                ReceptorEntregable,
                ResponsableGenerador,
                FrecuenciaEntregable,
                TiempoEntrega,
                TiempoRespuesta,
                FechaPublicacion,
                FechaModificacion
         FROM EN_Entregable E
	    LEFT JOIN EN_MarcoLegal ML ON E.IdMarcoLegal = ML.IdMarcoLegal
	    LEFT JOIN CO_Regulador R ON E.IdRegulador = R.IdRegulador
	    LEFT JOIN EN_ReceptorEntregable RE ON E.IdReceptorEntregable = RE.IdReceptorEntregable
	    LEFT JOIN EN_ResponsableGenerador RG ON E.IdResponsableGenerador = RG.IdResponsableGenerador
	    LEFT JOIN EN_FrecuenciaEntregable FE ON E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
	    --LEFT JOIN EN_TiempoEntrega TE ON E.IdTiempoEntrega = TE.IdTiempoEntrega
	    LEFT JOIN EN_TiempoRespuesta TR ON E.IdTiempoRespuesta = TR.IdTiempoRespuesta
	    WHERE E.IdEntregable = @IdEntregable
     END;
	--EXEC SP_EN_FormatoConsulta 10001
