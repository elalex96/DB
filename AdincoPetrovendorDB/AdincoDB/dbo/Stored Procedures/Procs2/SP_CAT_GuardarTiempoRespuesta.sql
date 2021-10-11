USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_GuardarTiempoRespuesta]    Script Date: 07/10/2021 12:18:44 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/10/2021
-- Description:	Agregado de un nuevo tiempo de entrega
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_GuardarTiempoRespuesta]
	-- Add the parameters for the stored procedure here
	@TiempoRespuesta NVARCHAR(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.EN_TiempoRespuesta
	(
		TiempoRespuesta,
		CreadoEn
	)
	VALUES
	(
		@TiempoRespuesta,
		GETDATE()
	);

END
