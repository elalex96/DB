-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <19/11/19>
-- Description:	<Agrega una nueva relación ( centro costros - flujo aprobacion de factura/comprobante ),>
-- =============================================
-- Author:	Daniel AC
-- Create date: 28/11/2019
-- Description:Agregar nuevos usuarios para notificación de agregar Pr y Relacionar PO Pedido
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarCentrosDeCostosFlujo]
    @CentroCosto NVARCHAR(300),
    @IdProveedor INT,
	@IdUsuario INT,    
    @numero VARCHAR(MAX),
    @IdFlujo INT,
	@IdFlujoFactura INT NULL,
	@IdFlujoComprobante INT NULL,
	@UsuariosNotPR NVARCHAR(MAX),
	@UsuariosNotPOPedido NVARCHAR(MAX)	
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @IdCentroCosto INT

    INSERT INTO [dbo].[CC_CentroCosto]
    (
        CentroCosto,
        IdProveedor,
        CreadoPor,
        CreadoEl,
        IsActivo,
        numero
    )
    VALUES
    (@CentroCosto, @IdProveedor, @IdUsuario, GETDATE(), 1, @numero)

    SELECT @IdCentroCosto = SCOPE_IDENTITY();

    IF EXISTS
    (
        SELECT 1
        FROM dbo.RelacionCentroCostoFlujoAprob
        WHERE IdCentroCosto = @IdCentroCosto
    )
    BEGIN
        UPDATE dbo.RelacionCentroCostoFlujoAprob
        SET Activo = 1
        WHERE IdCentroCosto = @IdCentroCosto
    END
    ELSE
    BEGIN
        INSERT INTO dbo.RelacionCentroCostoFlujoAprob
        (
            IdCentroCosto,
            IdFlujo,
			IdFlujoFactura,
			IdFlujoComprobante,
            Activo
        )
        VALUES
        (   @IdCentroCosto, -- IdCentroCosto - int
            @IdFlujo,       -- IdFlujo - int
			@IdFlujoFactura,
			@IdFlujoComprobante,
            1               -- Activo - bit
            )
    END



	---AGREGAR NOTIFICACIONES PARA USUARIOS DE NOT DE SOLICITUD DE CARGA DE PR 

 
	EXEC dbo.DEA_SP_AgregarActualizarNotificaciones @IdProveedor = @IdProveedor,        -- int
	                                                @IdUsuario = @IdUsuario,          -- int
	                                                @TipoNotificacion = N'NOT_CARGA_PR', -- nvarchar(max)
	                                                @Usuarios = @UsuariosNotPR,         -- nvarchar(max)
	                                                @IdCentroCosto = @IdCentroCosto       -- int
		
	

	-------AGREGAR NOTIFICACIONES PARA USUARIOS DE NOT DE SOLICITUD DE RELACIÓND DE PO PEDIDO  
	EXEC dbo.DEA_SP_AgregarActualizarNotificaciones @IdProveedor = @IdProveedor,        -- int
	                                                @IdUsuario = @IdUsuario,          -- int
	                                                @TipoNotificacion = N'SOLITAR_RELACION_PRPO', -- nvarchar(max)
	                                                @Usuarios = @UsuariosNotPOPedido,        -- nvarchar(max)
													@IdCentroCosto =@IdCentroCosto


END


