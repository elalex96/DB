
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_VerificarFacturaSiTieneRelacion'
)
    DROP PROCEDURE SP_FI_VerificarFacturaSiTieneRelacion
GO
-- =============================================
-- Author:		Manuel CD
-- Create date: 26-02-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_VerificarFacturaSiTieneRelacion]
    -- Add the parameters for the stored procedure here
    @IdFactura INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.FI_TransferFactura 
        WHERE IdFactura = @IdFactura
    )
       OR EXISTS
    (
        SELECT 1
        FROM dbo.CO_Registro
        WHERE IdFactura = @IdFactura
    )
	OR EXISTS(
		SELECT 1 
		FROM FI_FacturaPuntoEntrega
		WHERE IdFactura =  @IdFactura
	 )
        SELECT 1 AS Relacion;
    ELSE
        SELECT 0 AS Relacion;
END;