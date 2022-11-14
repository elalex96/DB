USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_CF_EliminarSecuenciaPorContrato'
)
    DROP PROCEDURE SP_EN_CF_EliminarSecuenciaPorContrato;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Daniel AC
-- Create date: <10/11/2022>
-- Description: <Se agrega limpieza de la secuencia de rutas solo por contrato>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_CF_EliminarSecuenciaPorContrato] 

    -- Add the parameters for the stored procedure here
    @Ruta VARCHAR(MAX),
    @IdContrato     int,
    @IdUsuario      int
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	DELETE FROM EN_SecuenciaCarpetas 
	WHERE IdContrato = @idContrato

	INSERT INTO dbo.AP_BitacoraErrores
	(HResult,
	 Mensaje,
	 StackTrace,
	 IdUsuario,
	 IdContrato,
	 FechaRegistro
	)
	VALUES
	(0, -- HResult - int
	CONCAT('Se eliminó la información de la tabla EN_SecuenciaCarpetas, por ruta no encontrada, Ruta: ',@Ruta), -- Mensaje - nvarchar(max)
	 'CONTRACT_FILES', -- StackTrace - nvarchar(max)
	 @IdUsuario, -- IdUsuario - int
	 @IdContrato,
	 GETDATE()
	);

END