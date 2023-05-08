
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <03-01-2019>
-- Description:	<Se consultan los clientes de un proveedor>
-- =============================================

CREATE PROCEDURE SP_PV_ConsultarClientes
    @IdProveedor INT,
    /*---------------------Parametros contrato---------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*---------------------Parametros contrato---------------------*/
AS
BEGIN
    SELECT CS.IdRelacion,
           P.RazonSocial
    FROM PV_ContratistaSubContratista CS
        INNER JOIN S_Proveedor P ON CS.IdSubContratista = P.IdProveedor
    WHERE CS.IdContratista = @IdProveedor
          AND CS.IsActivo = 1;
END;