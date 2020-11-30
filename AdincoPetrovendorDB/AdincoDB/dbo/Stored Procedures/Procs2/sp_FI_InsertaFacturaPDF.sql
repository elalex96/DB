-- =============================================
-- Author:	Josue Glez
-- Create date: 6-03-17
-- Description:	
-- =============================================
Create PROCEDURE [dbo].[sp_FI_InsertaFacturaPDF]
	-- Add the parameters for the stored procedure here
	@Documento nvarchar(max),
	@IdFactura int,
	@IdTipoDocumento int

AS
BEGIN
declare @IdPublicacion int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	insert into dbo.FI_Documento
	(Documento,
	idTipoDocumento,
	IdFactura
	)
	values
	(@Documento,
	@IdTipoDocumento,
	@IdFactura)
	
	set @IdPublicacion = (select @@IDENTITY)
	select @IdPublicacion as idpublicacion

END
