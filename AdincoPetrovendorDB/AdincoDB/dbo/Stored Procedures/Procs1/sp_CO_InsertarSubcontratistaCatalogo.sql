-- =============================================
-- Author:		Manuel Cruz
-- Create date: 08-06-17
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CO_InsertarSubcontratistaCatalogo
	-- Add the parameters for the stored procedure here
@IdSubcontratista    INT,
@IdCatalogoCuentasSH INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         INSERT INTO CO_SubcontratistaCatalogo
         ([IdSubcontratista],
          [IdCatalogoCuentasSH]
         )
         VALUES
         (@IdSubcontratista,
          @IdCatalogoCuentasSH
         );
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;

	--exec sp_CO_InsertarSubcontratistaCatalogo 10000,10000

