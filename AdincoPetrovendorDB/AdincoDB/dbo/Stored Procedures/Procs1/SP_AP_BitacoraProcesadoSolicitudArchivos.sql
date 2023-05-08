
-- =============================================
-- Autor:				Neri Garcia del Angel
-- Fecha de Creación:	15 de Febrero del 2023
-- Descripción:			Se agrega llenado de bitácora
-- de solicitud de archivos para llevar un control
-- de los procesos realizados
-- =============================================
CREATE PROCEDURE [dbo].[SP_AP_BitacoraProcesadoSolicitudArchivos] 
	@Mensaje NVARCHAR(1000),
	@Detalle NVARCHAR(2000),
	@IdUsuario INT = 0,
	@IdContrato INT = 0,
	@GeneradoDesde VARCHAR(100)
AS
BEGIN
	INSERT INTO AP_BitacoraProcesadoSolicitudArchivos (
		Mensaje,
		Detalle,
		IdUsuario,
		IdContrato,
		FechaRegistro,
		GeneradoDesde
		)
	VALUES (
		@Mensaje,
		@Detalle,
		@IdUsuario,
		@IdContrato,
		GETDATE(),
		@GeneradoDesde
		);
END;