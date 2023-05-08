-- =============================================
CREATE PROCEDURE SP_MPY_GuardarComentarioInterno
	-- Add the parameters for the stored procedure here
	@IdPRESES INT,
	@Comentario NVARCHAR(MAX),
	@IdUsuario	int,
	@IdEstatus	int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE Adinco.dbo.CO_SAPPRESES
		SET ComentarioInterno = @Comentario
	WHERE
		IdPRESES = @IdPRESES

	SELECT
		PSES.ComentarioInterno
	FROM Adinco.dbo.CO_SAPPRESES AS PSES
	WHERE PSES.IdPRESES = @IdPRESES

	declare @Id int
	select @Id = isnull(max(id),0)+1 from adinco..CO_SAPPreses_BiTACORA

	insert into adinco..CO_SAPPreses_BiTACORA values(@Id,@IdPRESES,@IdUsuario,@IdEstatus,getdate(),@Comentario)

END

