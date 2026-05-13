-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GuardarFacturaCliente]
@IdProveedor      int,
@IdSubcontratista int,
@Correo           varchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 --  update S_Proveedor 
	--set 
	--CorreoProveedor = @Correo
	--where IdProveedor = @IdSubcontratista

	INSERT INTO PV_ContratistaSubContratista
    (
		IdContratista,
		IdSubContratista,
		IsActivo,
		FechaRegistro,
		Correo	
    )
    VALUES
    (@IdProveedor, @IdSubcontratista, 1, GETDATE(), @Correo)

    SELECT @@identity


END
