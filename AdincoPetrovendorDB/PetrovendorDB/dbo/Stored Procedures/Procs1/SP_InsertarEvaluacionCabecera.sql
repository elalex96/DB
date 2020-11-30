-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <09/01/2018>
-- Description:	<Inserta la cabecera de cualquier tipo de evaluación al momento de terminar la transacción>
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertarEvaluacionCabecera]
@IdPedido INT,
@IdUsuarioEvaluador INT, -- Usuario de la sesion
@IdProveedorEvaluador INT,
@IdProveedorEvaluado INT, -- proveedor evaluado

@IdContrato INT,
@FechaRegistro DATETIME,

-- parametro de salida
@idOutPut int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    --DECLARE @IdProveedorEvaluador INT = (
				--						 SELECT up.IdProveedor 
				--						 FROM dbo.S_UsuarioProveedor up
				--						 WHERE up.IdUsuario = @IdUsuarioEvaluador
				--					    )


	INSERT INTO dbo.EP_EvaluacionProveedor
	(
	    IdPedido,
	    IdUsuarioEvaluador,
	    IdProveedorEvaluador,
	    TotalDePuntos,
	    IdProveedorEvaluado,
	    FechaRegistro,
	    IsActivo,
	    EstatusEvaluacion
	)
	VALUES
	(   
	    @IdPedido,         -- IdPedido - int
	    @IdUsuarioEvaluador,         -- IdUsuarioEvaluador - int
	    @IdProveedorEvaluador,         -- IdProveedorEvaluador - int
	    0,         -- TotalDePuntos - int
	    @IdProveedorEvaluado,         -- IdProveedorEvaluado - int
	    GETDATE(), -- FechaRegistro - datetime
	    1,      -- IsActivo - bit
	    2        -- EstatusEvaluacion - int  1 = contestada, 2 = sin contestar 
	)

	DECLARE @Id INT  
	SET @idOutPut = (SELECT @@IDENTITY)
	SELECT @idOutPut


END
