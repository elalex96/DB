-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03/07/2018
-- Description:	Insercion de datos de la aceptacion del pedido desde el webservice
-- =============================================
create PROCEDURE [dbo].[SP_MPY_WS_AgregarAceptacionPedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor VARCHAR(20),
    @IdPedido NVARCHAR(20),
    @Comentario VARCHAR(MAX),
    @IdDomicilioEntrega NVARCHAR(20),
    @IdSubContratista NVARCHAR(20),
    @IdContrato NVARCHAR(MAX),
	@consecutivo NVARCHAR(MAX),
	@navcode NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO dbo.MPY_RegistroWS
	(
	    RFC,
	    Fecha
	)
	VALUES
	(   @IdProveedor,      -- RFC - nvarchar(50)
	    GETDATE() -- Fecha - datetime
	    )

    -- Insert statements for procedure here
	INSERT INTO dbo.MPY_MM_AceptacionPedido
	(
	    IdProveedor,
	    IdPedido,
	    Comentario,
	    Activo,
	    Creado,
	    IdDomicilioEntrega,
	    IdSubContratista,
	    IdContrato,
		consecutivo,
		navcode
	)
	VALUES
	(   @IdProveedor,         -- IdProveedor - int
	    @IdPedido,         -- IdPedido - int
	    @Comentario,        -- Comentario - varchar(1500)
	    1,      -- Activo - bit
	    GETDATE(), -- Creado - datetime
	    @IdDomicilioEntrega,         -- IdDomicilioEntrega - int       -- CreadorPor - int
	    @IdSubContratista,         -- IdSubContratista - int
		@IdContrato,          -- IdContrato - int
	    @consecutivo,
		@navcode
		)

	SELECT @@IDENTITY

END