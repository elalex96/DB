-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <31/06/2018>
-- Description:	<Valida que un cliente no tenga relación con alguna cuenta bancaria o contacto>
-- =============================================
CREATE PROCEDURE SP_ValidarClienteAsociado @IdProveedor      INT,
                                           @IdSubcontratista INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @varContactos INT=
(
    SELECT COUNT(*)
    FROM dbo.S_ContactoContratistaSubContratista ccsc
         INNER JOIN dbo.PV_ContratistaSubContratista csc ON csc.IdRelacion = ccsc.IdContratistaSubContratista
    WHERE csc.IdSubContratista = @IdSubcontratista
          AND csc.IdContratista = @IdProveedor
          AND ccsc.IsActivo = 1
          AND csc.IsActivo = 1
);
         DECLARE @varCuentasBancarias INT=
(
    SELECT COUNT(*)
    FROM dbo.PV_CuentaBancariaSubContratista cbsc
         INNER JOIN dbo.PV_CuentaBancaria cb ON cb.DatoBancarioID = cbsc.IdCuentaBancaria
    WHERE cbsc.IdSubcontratista = @IdSubcontratista
          AND cbsc.IsActivo = 1
          AND cb.IdProveedor = @IdProveedor
);
         SELECT @varContactos AS ContactosAsociados,
                @varCuentasBancarias AS CuentasSAsociadas;
     END;
