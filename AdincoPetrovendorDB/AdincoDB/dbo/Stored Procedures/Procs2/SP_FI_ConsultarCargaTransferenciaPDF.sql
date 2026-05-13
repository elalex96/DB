-- =============================================
-- Author:		JG
-- Create date: 26-12-2016
-- Description:	Consulta si existe archivo cargado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarCargaTransferenciaPDF] 
--128
-- Add the parameters for the stored procedure here
@IdTransfer INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
		 DECLARE @IsValidoArchivo NVARCHAR(50);
		 DECLARE @Archivo NVARCHAR(50)
         -- Insert statements for procedure here
 SET @Archivo = (Select PDF from FI_Transfer  where IdTransferencia = @IdTransfer) 

 IF (@Archivo = null)
	SET @IsValidoArchivo = 'NO'
ELSE IF @Archivo = ''
	SET @IsValidoArchivo = 'NO'
ELSE 
	SET @IsValidoArchivo = 'Si'
END
	 --SET @IsValidoArchivo =(
				--SELECT
                --CASE ISNULL(T.PDF, 'NO')
                    --WHEN 'NO'
                    --THEN 'No'
                    --ELSE 'Si'
				
					
             --   END 
	--		 AS Cargado
    --     FROM FI_Transfer AS T
    --     WHERE(T.IdTransferencia =@IdTransfer))

		 SELECT ISNULL(@IsValidoArchivo,'No') AS Cargo



    