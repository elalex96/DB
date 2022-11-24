-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/07/2017
-- Description:	ALTA ACEPTACION DE PEDIDO 
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 23/03/2018
-- Description:	AGREGUE PARAMETROS PARA IDENTIFICAR EL TIPO DE ACEPTACIÓN NACIONAL/EXTRANJERO
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 16/10/2019
-- Description:	AGREGUE PARAMETROS PARA INDICAR QUE SE ESTA PIDIENDO CARTA DE CONTENIDO
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 11/08/2021
-- Description:	Validacion para agregar automaticamente aceptaciones de WD Admin sin carta CN
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarAceptacionPedidoEncabezado]
    @IdPedido INT,
    @CreadoPor INT,
    @IdProveedor INT,
    @DescripcionAceptacionPedido NVARCHAR(300),
    @NombreUsuarioRecibe NVARCHAR(300),
    @NombreUsuarioEntrega NVARCHAR(300),
    @IdDomicilioEntrega INT,
    @NoPedirCarta BIT = NULL	
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @ID_PROVEEDOR_PEDIDO INT = NULL
    DECLARE @ID_NACIONALIDAD_ACTUAL INT = NULL
    DECLARE @ID_PAIS_ACTUAL INT = NULL
    DECLARE @ID_REGIMEN_ACTUAL INT = NULL
    DECLARE @IdAceptacionPedido INT
	DECLARE @IDCONTRATO INT = (SELECT TOP 1 IdContrato FROM MM_Pedido WHERE IdPedido = @IdPedido)



    SELECT @ID_PROVEEDOR_PEDIDO = P.IdSubcontratista,
           @ID_NACIONALIDAD_ACTUAL = S.IdNacionalidad,
           @ID_PAIS_ACTUAL = S.IdPais,
           @ID_REGIMEN_ACTUAL = S.IdTipoRegimen
    FROM dbo.MM_Pedido P
        INNER JOIN dbo.S_Proveedor S
            ON S.IdProveedor = P.IdSubcontratista
    WHERE P.IdPedido = @IdPedido


    INSERT INTO dbo.MM_AceptacionPedido
    (
        [IdProveedor],
        [IdPedido],
        [Comentario],
        [NombreUsuarioEntrega],
        [Activo],
        [Creado],
        [CreadorPor],
        [IdDomicilioEntrega],
        [RecibidoPor],
        [NombreRecibidoPor],
        [IdNacionalidadProveedor],
        [IdRegimenProveedor],
        [IdPaisProveedor]
    )
    VALUES
    (@IdProveedor, @IdPedido, @DescripcionAceptacionPedido, @NombreUsuarioEntrega, 1, GETDATE(), @CreadoPor,
     @IdDomicilioEntrega, @CreadoPor, @NombreUsuarioRecibe, @ID_NACIONALIDAD_ACTUAL, @ID_REGIMEN_ACTUAL,
     @ID_PAIS_ACTUAL)

    SELECT @IdAceptacionPedido = SCOPE_IDENTITY()

    -- En caso de que el bit PedirCarta = 1 no pedir carta
	--EN CASO DE SER WD ADMIN AGREGARLO COMO PedirCarta = 1
	--IF @IDCONTRATO = 3
	IF @IDCONTRATO = 10145--CNH-WD ADMIN
	BEGIN 
		INSERT INTO dbo.RelacionCartaCNPedido
		(
			IdPedido,
			IdAceptacionPedido,
			PedirCarta,
			CreadoPor,
			FechaCreacion
		)
		SELECT @IdPedido,
			   @IdAceptacionPedido,
			   0,
			   @CreadoPor,
			   GETDATE()
	END
	ELSE
	BEGIN 
		INSERT INTO dbo.RelacionCartaCNPedido
		(
			IdPedido,
			IdAceptacionPedido,
			PedirCarta,
			CreadoPor,
			FechaCreacion
		)
		SELECT @IdPedido,
			   @IdAceptacionPedido,
			   1,
			   @CreadoPor,
			   GETDATE()
	END
	
    


    SELECT @IdAceptacionPedido AS IdAceptacion,
           ISNULL(@ID_NACIONALIDAD_ACTUAL, 0)


END