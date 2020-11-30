-- =============================================
-- Author:		
-- ALTER date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_FormatoConsultaEntrega] 
	-- Add the parameters for the stored procedure here
@IdEntregable INT,
@idContrato int =0,
@idUsuario int =0
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
                Articulo
               -- Inciso
                
         FROM EN_Entregable E
	    LEFT JOIN EN_MarcoLegal ML ON E.IdMarcoLegal = ML.IdMarcoLegal

	 

	    WHERE E.IdEntregable = @IdEntregable
     END;
	--EXEC SP_EN_FormatoConsulta 10001

