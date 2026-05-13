-- =============================================
-- Author:		Manuel Cruz
-- Create date: 7-02-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PvInsertaPost]
	-- Add the parameters for the stored procedure here
	@Descripcion nvarchar(max),
	@IdProveedor int,
	@ImagenPub nvarchar(max),
	@IdUsuario int 

AS
BEGIN
declare @FechaAlta datetime = getdate()
declare @IsEliminado bit
declare @IdPublicacion int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	insert into dbo.PV_Publicacion
	(Descripcion,
	IdProveedor,
	FechaAlta,
	FechaPublicacion,
	IsPublicado,
	Imagen,
	IdUsuario)
	values
	(@Descripcion,
	@IdProveedor,
	@FechaAlta,
	@FechaAlta,
	0,
	@ImagenPub,
	@IdUsuario)
	
	set @IdPublicacion = (select @@IDENTITY)
	select @IdPublicacion as idpublicacion

END

