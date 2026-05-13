-- =============================================
-- Author:	Josue Gonzalez
-- Create date: 15-05-17
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_FI_DescargaTransfer] 
-- Add the parameters for the stored procedure here
@IdContrato INT,
@Facturas varchar(max)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
	

select PDF, NombreExtencionArchivo
	from FI_Transfer 
	where idContrato = @IdContrato
	
	AND IdTransferencia in (select * from   [fn_FI_StringList2Table](@Facturas) )
END;