-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_ValidaCuentaBancoProveedor 
-- Add the parameters for the stored procedure here
@IdProveedor INT = 0, 
@IdUsuario   INT = 0
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @CantidadCuentas INT;

        -- Insert statements for procedure here
        SELECT @CantidadCuentas = COUNT(1)
        FROM PV_CuentaBancaria CB
        WHERE CB.IdProveedor = @IdProveedor;
        SELECT CASE
                   WHEN @CantidadCuentas > 0
                   THEN 1
                   ELSE 0
               END AS Cuentas;
    END;
