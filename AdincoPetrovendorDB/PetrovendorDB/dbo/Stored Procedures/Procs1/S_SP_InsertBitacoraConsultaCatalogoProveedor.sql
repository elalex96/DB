
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <26-03-2018>
-- Description:	<Se inserta en bitacora cuando se consulta un catalogo>
-- =============================================

CREATE procedure S_SP_InsertBitacoraConsultaCatalogoProveedor
	@IdProveedorConsultado INT,
	@Motivo varchar(1500),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	INSERT INTO dbo.S_BitacoraConsultaCatalogoProveedor
	(
	    IdUsuario,
	    IdProveedorConsultado,
	    Motivo,
	    FechaConsulta
	)
	VALUES
	(   @IdUsuario,                    -- IdUsuario - int
	    @IdProveedorConsultado,                    -- IdProveedorConsultado - int
	    @Motivo,                   -- Motivo - varchar(1500)
	    GETDATE() -- FechaConsulta - smalldatetime
	)

	SELECT @@IDENTITY
END