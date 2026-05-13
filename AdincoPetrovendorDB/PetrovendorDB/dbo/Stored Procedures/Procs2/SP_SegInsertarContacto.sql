-- =============================================
-- Author:		Manuel Cruz
-- Create date: 30-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegInsertarContacto]
	-- Add the parameters for the stored procedure here
	@IdTipoContacto int,
	@Nombre nvarchar(100),
	@Apellidos nvarchar(100),
	@Email nvarchar(50),
	@Telefono nvarchar(20),
	@Ispredeterminado bit,
	@Idproveedor int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into dbo.S_Contacto
	(IdTipoContacto,
	Nombres,
	Apellidos,
	Email,
	Telefono,
	IsPredeterminado,
	IdProveedor,
	IsEliminado)
	values
	(@IdTipoContacto,
	@Nombre,
	@Apellidos,
	@Email,
	@Telefono,
	@Ispredeterminado,
	@Idproveedor,
	0)

	select 'El contacto ha sido registrado' as Mensaje

END

