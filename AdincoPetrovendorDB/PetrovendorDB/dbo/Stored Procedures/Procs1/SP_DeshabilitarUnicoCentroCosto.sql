USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DeshabilitarUnicoCentroCosto'
)
    DROP PROCEDURE SP_DeshabilitarUnicoCentroCosto;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <27-09-2019>
-- Description:	<los proveedores que se encuentren en esta tabla se deshabilitara el check unico centro de costo de la solicitud de pedido>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DeshabilitarUnicoCentroCosto] @IdProveedor INT
AS
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM dbo.DEA_Proveedor (NOLOCK)
        WHERE IdProveedor = @IdProveedor
		AND ISNULL(Activo, 0) = 1
    )
        SELECT 1
    ELSE
        SELECT 0

END