-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <18/12/19>
-- Description:	<Registra una nueva notificacion>
-- =============================================
CREATE PROCEDURE [dbo].[SP_N_AgregarNuevaNotificacion]
--@IdDocumento int,
@IdTipoOperacion int, 
@IdFlujoTarea int,
@IdProveedor int, -- proveedorActual
--@IdUsuario INT, -- usuarioActual
@IdEstatusOperacion int, 
--@IdEstadoFlujo INT,
@IdOperacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TextoCabecera NVARCHAR(2000) = NULL;
	DECLARE @IdTabla INT;
	DECLARE @IdTipoNotificacion INT;
	DECLARE @IdProveedorNotificacion INT -- proveedor operadora

	DECLARE @IdUsuario INT = 0;
	SELECT
	@IdUsuario = IdAsignador
	FROM dbo.TA_Operacion
	WHERE IdOperacion = @IdOperacion

	--BEGIN TRAN tranNotificacion
	--BEGIN TRY
				IF ( @IdEstatusOperacion = 1 OR @IdEstatusOperacion = 9 ) -- en aprobación / 9 = para operaciones sin flujotarea
				BEGIN
							IF @IdTipoOperacion = 2 -- requisición
							BEGIN
									SELECT 
									@IdTabla = IdDocumento,
									@IdProveedorNotificacion = IdProveedor 
									FROM dbo.TA_Operacion WHERE IdOperacion = @IdOperacion

									--SET @TextoCabecera = 'Aprobación de la solicitud de pedido N.' + LTRIM(@IdTabla) + ' pendiente';
									SET @IdTipoNotificacion = 4;
							END
							ELSE IF @IdTipoOperacion = 9 -- pedido
							BEGIN
									SELECT
									@IdTabla = ps.IdPedido,
									@IdProveedorNotificacion = O.IdProveedor
									FROM dbo.MM_Pedido P
									LEFT JOIN dbo.TA_Operacion O 
									ON O.IdDocumento = P.IdSolicitudPedido
									LEFT JOIN dbo.MM_Pedidos Ps
									ON Ps.IdIdentificador = p.IdPedido
									AND ps.IdProveedorCliente = p.IdProveedorCompras
									WHERE
									O.IdOperacion = @IdOperacion
									AND O.IdTipoOperacion = 9
									AND O.NoVersion = P.Version

									--SET @TextoCabecera = 'Aprobación del pedido N.' + LTRIM(@IdTabla) + ' pendiente';
									SET @IdTipoNotificacion = 6;																				
							END
							ELSE IF @IdTipoOperacion = 10 -- factura
							BEGIN

									SELECT 
									@IdTabla = AF.IdAceptacionPedido,
									@IdProveedorNotificacion = AP.IdProveedor
									FROM dbo.MM_AceptacionFactura AF
									LEFT JOIN dbo.TA_Operacion O
										ON O.IdDocumento = AF.IdAceptacionFactura
									LEFT JOIN dbo.MM_AceptacionPedido AP
										ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
									WHERE O.IdOperacion = @IdOperacion
						
									IF @IdFlujoTarea <> 0 -- existe un flujo de aprobacion
									BEGIN										
											--SET @TextoCabecera = 'Aprobación de la factura N.' + LTRIM(@IdTabla) + ' pendiente';
											SET @IdTipoNotificacion = 5;
									END
									ELSE -- factura enviada sin flujo de aprobación
									BEGIN
											--SET @TextoCabecera = 'Factura N.' + LTRIM(@IdTabla) + ' sin flujo de aprobación,pendiente de asignar';
											SET @IdTipoNotificacion = 1;
									END

							END
							ELSE IF @IdTipoOperacion = 14 -- compra directa
							BEGIN
							        -- se agrega el idTabla despues de que se genera el idPedido
									SELECT
									--@IdTabla = Ps.IdPedido, -- orden compra = idFactura
									@IdProveedorNotificacion = O.IdProveedor
									FROM dbo.FI_Factura FI
									LEFT JOIN dbo.TA_Operacion O
										ON O.IdDocumento = FI.IdFactura
									--LEFT JOIN dbo.MM_Pedidos Ps
									--	ON Ps.IdIdentificador = FI.IdFactura
									WHERE o.IdOperacion = @IdOperacion
									--AND Ps.IdTipoPedido = 1 -- compra directa
										
									--SET @TextoCabecera = 'Aprobación de la compra directa N.' + LTRIM(@IdTabla) + ' pendiente';
									SET @IdTipoNotificacion = 7;
				
							END
							ELSE IF @IdTipoOperacion = 16 -- pedimento comprobante
							BEGIN
									SELECT
									@IdTabla = AP.IdAceptacionPedido,
									@IdProveedorNotificacion = AP.IdProveedor
									FROM dbo.FI_AceptacionPedido_PedimentoComprobante APC
									LEFT JOIN dbo.TA_Operacion O 
										ON O.IdDocumento = APC.IdPedimentoComprobante
									LEFT JOIN dbo.MM_AceptacionPedido AP
										ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
									WHERE O.IdOperacion = @IdOperacion

									IF @IdFlujoTarea <> 0 -- existe un flujo de aprobacion
									BEGIN
											--SET @TextoCabecera = 'Aprobación del pedimento/comprobante N.' + LTRIM(@IdTabla) + ' pendiente';
											SET @IdTipoNotificacion = 9;
									END
									ELSE -- pedimento comprobante sin flujo de aprobacion
									BEGIN
											--SET @TextoCabecera = 'Pedimento/comprobante ' + LTRIM(@IdTabla) + ' sin flujo de aprobación,pendiente de asignar'
											SET @IdTipoNotificacion = 2;
									END	

							END
							ELSE IF @IdTipoOperacion IS NULL -- carta CN 
							BEGIN

									SELECT 
									@IdTabla = ap.IdAceptacionPedido,
									@IdProveedorNotificacion = ap.IdProveedor
									FROM dbo.MM_AceptacionCartaPCN ACN
									LEFT JOIN dbo.MM_AceptacionPedido AP
									ON AP.IdAceptacionPedido = ACN.IdAceptacionPedido
									WHERE ap.IdAceptacionPedido = @IdOperacion -- @idoperacion
									GROUP BY AP.IdAceptacionPedido,AP.IdProveedor
										
									--SET @TextoCabecera = 'Aprobación de la carta CN N.' + LTRIM(@IdTabla) + ' pendiente';
									SET @IdTipoNotificacion = 8;						
							END

				

				INSERT INTO dbo.Notificacion
				(
					IdTipoNotificacion,
					IdTabla,
					IdProveedor,
					IdUsuario,
					Cabecera,
					Descripcion,
					IdOperacion,
					FechaRegistro,
					Activo,
					Eliminado
				)
				VALUES
				(
					@IdTipoNotificacion,
					@IdTabla,
					@IdProveedorNotificacion,
					@IdUsuario, -- usuario que registro la operación
					@TextoCabecera,
					'',
					@IdOperacion,
					GETDATE(),
					1,
					0
				)

				END

				--SELECT SCOPE_IDENTITY();
	--			COMMIT TRAN tranNotificacion

	--END TRY
	--BEGIN CATCH
	--	ROLLBACK TRAN tranNotificacion
	--	SELECT
	--		ERROR_NUMBER()    AS ErrorNumber,
	--		ERROR_SEVERITY()  AS ErrorSeverity,
	--		ERROR_STATE()     AS ErrorState,
	--		ERROR_PROCEDURE() AS ErrorProcedure,
	--		ERROR_LINE()      AS ErrorLine,
	--		ERROR_MESSAGE()   AS ErrorMessage
	--END CATCH


END
