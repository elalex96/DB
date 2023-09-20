USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'INS_APP_GuardarLogBitacora'
)
    DROP PROCEDURE INS_APP_GuardarLogBitacora;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19/09/2023
-- Description:	Metodo generico para el guardado de logs de serivicos en adinco
-- =============================================
CREATE PROCEDURE [dbo].[INS_APP_GuardarLogBitacora]
	-- Add the parameters for the stored procedure here
	@Tipo VARCHAR(1000),
	@Mensaje VARCHAR(1000),
	@Detalle VARCHAR(1000),
	@UsuarioId INT,
	@ContratoId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO AP_Bitacora(
		Tipo,
		Mensaje,
		Detalle,
		UsuarioId,
		ContratoId,
		Fecha
	)
	VALUES
	(
		@Tipo,
		@Mensaje,
		@Detalle,
		@UsuarioId,
		@ContratoId,
		GETDATE()
	);

	SELECT SCOPE_IDENTITY() AS Id;

END
