
CREATE PROCEDURE [dbo].[CO_ModificaPuntosdeEntrega]
	@Nombre				NVARCHAR(Max),
	@TagPatinMedicion	NVARCHAR(100),
	@TipoMedidor		NVARCHAR(100),
	@TagMedidor			NVARCHAR(100),
	@Clasificacion		NVARCHAR(100),
	@PuntoEntregaID		INT,
	@idusuario			INT =0,
	@idContrato			INT=0
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 08/03/18
-- Description:Modifica os puntos de entrega
-- =============================================
-- 20180504	BAAC	Se modifica para agregar mas campos a la tabla por reportes de la CNH
-- =============================================
	SET NOCOUNT ON
-- =============================================
	DECLARE @cont INT
	SELECT @cont=COUNT(puntoEntregaID) FROM  CO_PuntosdeEntrega 
	WHERE Nombre= LTRIM(RTRIM(@Nombre))
	AND PuntoEntregaID	<>	@PuntoEntregaID

	IF (@cont>=1)
		BEGIN
			PRINT('Ya hay un punto de entrega con el mismo nombre');
		END
	ELSE
	BEGIN
		UPDATE CO_PuntosdeEntrega 
			SET Nombre	=	 LTRIM(RTRIM(@Nombre)),
				TagPatinMedicion	=	LTRIM(RTRIM(@TagPatinMedicion)),
				TipoMedidor			=	LTRIM(RTRIM(@TipoMedidor)),
				TagMedidor			=	LTRIM(RTRIM(@TagMedidor)),
				Clasificacion		=	LTRIM(RTRIM(@Clasificacion)),
				ModificadoPor		=	@idusuario,
				ModificadoEl		=	GETDATE()
		WHERE
			PuntoEntregaID = @PuntoEntregaID
	END
END

