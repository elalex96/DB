-- =============================================
-- Author:		Manuel CD
-- Create date: 31-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_InsertarContratoCampos] 
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdCampo    INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             INSERT INTO [dbo].[PC_ContratoCampo]
		  ([IdContrato],
		   [IdCampo],
		   [CreadoPor],
		   [CreadoEn]
		  )
             VALUES
		  (@IdContrato,
		   @IdCampo,
		   1,
		   GETDATE()
		  );
         END;
