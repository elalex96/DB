-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegInsertarContactoPA]
	-- Add the parameters for the stored procedure here
	@IdTipoContacto int,
	@Nombres nvarchar(100),
	@Apellidos nvarchar(100),
	@Email nvarchar(50),
	@Telefono nvarchar(20),
	@Ispredeterminado bit,
	--@IdContratistaSubcontratista int,
	@Titulo varchar(50),
	@Puesto varchar(50),
	@Celular_VENTAS varchar(10),
	@IdProveedor int


AS
--declare @IdContactoRegistrado int
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		declare @ExisteContactoPredeterminado bit
	set @ExisteContactoPredeterminado = (select IsPredeterminado from S_Contacto_PA where IsPredeterminado = 1 and IdProveedor = @IdProveedor and IsEliminado = 0 )

	if @ExisteContactoPredeterminado > 0
	begin
	if @Ispredeterminado > 0
	begin
	update S_Contacto_PA
	set IsPredeterminado = 0
	where IsPredeterminado = 1
	and IdProveedor = @IdProveedor
	end
	end
    -- Insert statements for procedure here
	insert into dbo.S_Contacto_PA
	(IdTipoContacto,
	Nombres,
	Apellidos,
	Email,
	Telefono,
	--IdContratistaSubContratista,
	IsPredeterminado,
	IsEliminado,
	Titulo,
	Puesto,
	Celular_VENTAS,
	IdProveedor)
	values
	(@IdTipoContacto,
	@Nombres,
	@Apellidos,
	@Email,
	@Telefono,
	--@IdContratistaSubcontratista,
	@Ispredeterminado,
	0,
	@Titulo,
	@Puesto,
	@Celular_VENTAS,
	@IdProveedor
	)


	select 'El contacto ha sido registrado' as Mensaje

END


/****** Object:  StoredProcedure [dbo].[SP_ValidarCorreoContacto]    Script Date: 11/8/2017 3:31:35 PM ******/
SET ANSI_NULLS ON
