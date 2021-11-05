
CREATE PROCEDURE [dbo].[SP_EN_FormatoConsultaEntrega] --13254,3,10
	-- Add the parameters for the stored procedure here
@IdEntregable INT,
@idContrato int =0,
@idUsuario int =0
AS
     BEGIN
	-- =============================================
    -- Author:  Daniel AC
    -- Create date: 2020-05-11
    -- Description: Se agregar NOLOCKS en las tablas que tienen mas recurrencia y referencias al objero dbo
    -- =============================================
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
         FROM dbo.EN_Entregable E (NOLOCK)
	     LEFT JOIN dbo.EN_MarcoLegal ML (NOLOCK)
			ON E.IdMarcoLegal = ML.IdMarcoLegal
	    WHERE E.IdEntregable = @IdEntregable
     END;

