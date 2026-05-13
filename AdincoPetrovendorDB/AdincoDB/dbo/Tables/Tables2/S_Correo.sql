CREATE TABLE [dbo].[S_Correo] (
    [IdCorreo]    INT            IDENTITY (1, 1) NOT NULL,
    [Asunto]      NVARCHAR (MAX) NULL,
    [Cuerpo1]     NVARCHAR (MAX) NULL,
    [Cuerpo2]     NVARCHAR (MAX) NULL,
    [Descripcion] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_S_Correo] PRIMARY KEY CLUSTERED ([IdCorreo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

