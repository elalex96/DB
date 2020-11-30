-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03/07/2018
-- Description:	Inserta a los aprobadores de la carta de contenido nacional desde el webservice
-- =============================================
CREATE procedure [dbo].[SP_MPY_WS_AgregarAprobadoresPCN] 
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT,
	@Nombre NVARCHAR(MAX),
	@Correo NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.MPY_CN_Aprobadores
	(
	    IdAceptacionPedido,
	    Nombre,
	    Correo
	)
	VALUES
	(   @IdAceptacionPedido,        -- IdAceptacionPedido - int
	    @Nombre,      -- Nombre - nvarchar(max)
	    @Correo
	    )
END
