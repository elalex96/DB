-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/03/2022>
-- Description:	<Guardar fecha vigencia REPSE>
-- =============================================
ALTER PROCEDURE SP_DOC_AgregarFechaVigenciaREPSE 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@FechaVigenciaREPSE DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE S_Proveedor
	SET FechaVigenciaREPSE = @FechaVigenciaREPSE
	WHERE IdProveedor = @IdProveedor;

END
GO
