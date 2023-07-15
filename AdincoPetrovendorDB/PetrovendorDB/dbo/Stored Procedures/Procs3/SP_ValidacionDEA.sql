USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ValidacionDEA'
)
    DROP PROCEDURE SP_ValidacionDEA;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/08/2021
-- Description:	Validacion Operadora DEA
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/07/2023
-- Description:	descarte de amatitlan
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidacionDEA] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RFC_ACTUAL NVARCHAR(100) = (SELECT RFC FROM dbo.S_Proveedor (NOLOCK) WHERE IdProveedor = @IdProveedor);

	DECLARE @PROVEEDORDEA INT = (SELECT TOP 1 COUNT(RFC) FROM DEA_Proveedor (NOLOCK) WHERE RFC = @RFC_ACTUAL AND RFC <> 'PAM140722DK6');

	IF @PROVEEDORDEA > 0
	BEGIN
		
		SELECT 'true'

	END
	ELSE
	BEGIN

		SELECT 'false'

	END

END
