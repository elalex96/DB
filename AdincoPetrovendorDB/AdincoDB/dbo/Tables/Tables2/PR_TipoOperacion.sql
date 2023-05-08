CREATE TABLE [dbo].[PR_TipoOperacion] (
    [id_]     INT      IDENTITY (1, 1) NOT NULL,
    [pozo_id] INT      NULL,
    [fecha]   DATETIME NULL,
    [Estado]  INT      NULL,
    [fila]    INT      NULL
);

